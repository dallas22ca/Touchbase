class Importer
  
  def self.from_blob blob, user_id, overwrite = false
    file = File.new("tmp/#{[user_id, "blob", Time.now.to_i].join}.csv", "w+")
    File.open(file.path, "w") {|f| f.write(blob.strip) }
    output = from_file file.path, user_id, overwrite
    File.delete file.path
    output
  end
  
  def self.from_file path, user_id, overwrite = false
    warnings = []
    user = User.find user_id
    spreadsheet = open_spreadsheet path
    structure = structurize spreadsheet.row(1)
    
    if structure
      permalinks = structure[:headers].map { |h| h[:permalink] }
      
      structure[:headers].each do |header|
        if header[:permalink] != "name"
          Field.create user_id: user_id, title: header[:title], permalink: header[:permalink]
        end
      end
    
      (structure[:first_data_row]..spreadsheet.last_row).each do |i|
        progress = ((i * 100) / spreadsheet.count).round
        data = Hash[[permalinks, spreadsheet.row(i).map{ |c| c.to_s.strip }].transpose]
        name = data.delete("name")
        contact = user.save_contact name: name, data: data, overwrite: overwrite
        user.update_column :import_progress, progress
        warnings.push contact.errors.full_messages unless contact.errors.empty?
        warnings.push contact.warnings unless contact.warnings.empty?
      end
      
      { 
        success: true, 
        warnings: warnings
      }
    else
      { 
        success: false, 
        errors: "The file provided does not have headers."
      }
    end
  end
  
  def self.structurize columns
    name_found = false
    headers = []

    columns.each do |title|
      title = title.to_s.strip
      title = "Email" if title.downcase == "email address"
      title = "Address" if title.downcase == "mailing address"
      
      if !name_found && title.downcase.include?("name")
        name_found = true
      end
      
      field = {
        title: title,
        permalink: title.parameterize
      }
      
      headers.push field
    end
    
    if name_found
      {
        headers: headers,
        first_data_row: 2
      }
    else
      headers.delete_at 0
      default_name_field = {
        title: "Name",
        permalink: "name"
      }
      
      {
        headers: [default_name_field] + headers,
        first_data_row: 1
      }
    end
  end

  def self.open_spreadsheet path
    file = File.open path    
    case File.extname(file)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
end