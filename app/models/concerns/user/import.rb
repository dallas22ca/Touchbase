class User
  module Import
    extend ActiveSupport::Concern
    
    def self.from_file path, user_id, overwrite = false
      spreadsheet = open_spreadsheet path
      user = User.find user_id
      warnings = []
      
      structure = structurize spreadsheet.row(1)
      
      if structure
        header_permalinks = structure[:headers].map { |h| h[:permalink] }
      
        (structure[:first_data_row]..spreadsheet.last_row).each do |i|
          row = Hash[[header_permalinks, spreadsheet.row(i).map{ |c| c.strip }].transpose]
          contact = user.save_contact row, overwrite
          warnings.push contact[:warnings] if contact[:warnings].any?
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
        title = title.strip
        title = "Email" if title.downcase == "email address"
        title = "Address" if title.downcase == "mailing address"
        
        if !name_found && title.downcase.include?("name")
          name_found = true
        end
        
        field = {
          title: title,
          permalink: title.parameterize,
          type: "string"
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
          permalink: "name",
          type: "string"
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
end