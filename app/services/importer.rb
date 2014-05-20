class Importer
  
  def initialize(user_id, src = "file", overwrite = false, declared_path = "")
    @src = src
    @user_id = user_id
    @overwrite = overwrite
    @declared_path = declared_path
    write_blob if src == "blob" && declared_path.blank?
  end
  
  def path
    if @declared_path.blank?
      if @src == "blob"
        @path ||= file.path
      else
        @path ||= user.file.path
      end
    else
      @path ||= @declared_path
    end
  end
  
  def file
    @file ||= File.new("tmp/#{[@user_id, "blob", Time.now.to_i].join}.csv", "w+")
  end
  
  def write_blob
    @write_blob ||= File.open(file.path, "w") { |f| f.write(user.blob.to_s.strip) }
  end
  
  def user
    @user ||= User.find @user_id
  end
  
  def spreadsheet
    @spreadsheet = open_spreadsheet
  end
  
  def create_headers
    headers.each do |header|
      if header[:permalink] != "name"
        Field.create user_id: @user_id, title: header[:title], permalink: header[:permalink]
      end
    end
    
    headers
  end
  
  def permalinks
    headers.map { |h| h[:permalink] }
  end
  
  def import
    warnings = []
    
    if headers
      create_headers
      row_count = spreadsheet.count
    
      (2..spreadsheet.last_row).each do |i|
        progress = (i * 100) / row_count
        data = Hash[[permalinks, spreadsheet.row(i).map{ |c| c.to_s.strip }].transpose]
        contact = user.save_contact(data.merge({ overwrite: @overwrite }))
        user.update_column :import_progress, progress if progress % 1 == 0
        warnings.push contact.errors.full_messages unless contact.errors.empty?
        warnings.push contact.warnings unless contact.warnings.empty?
      end
      
      output = { 
        success: true, 
        warnings: warnings
      }
    else
      output = { 
        success: false, 
        errors: "The file provided does not have headers."
      }
    end
    
    delete_file
    output
  end
  
  def delete_file
    if @src == "blob" && @declared_path.blank?
      File.delete(path) if File.exists?(path)
    end
  end
  
  def headers
    name_found = false
    headers = []

    spreadsheet.row(1).each do |title|
      title = "#{title}".to_s.strip
      title = "Email" if title.downcase == "email address"
      title = "Address" if title.downcase == "mailing address"
      
      if !name_found && (title.parameterize == "name" || title.parameterize == "first-name")
        name_found = true
      end
      
      field = {
        title: "#{title}",
        permalink: "#{title.parameterize}",
        data_type: "string"
      }
      
      headers.push field
    end
    
    if name_found
      headers
    else
      false
    end
  end

  def open_spreadsheet
    file = File.open path
    case File.extname(file)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
end