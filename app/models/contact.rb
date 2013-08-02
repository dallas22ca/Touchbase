class Contact < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id
  
  scope :pending, -> { where("pending_data != ''") }
  
  before_save :set_data, :sync_fields
  
  def set_data
    self.data ||= {}
    self.pending_data ||= {}
  end
  
  def ignore_pending_data
    update_attributes pending_data: nil
  end
  
  def sync_fields
    self.original_data = data
    prepared_data = {}
    
    data.each do |k, v|
      field = user.fields.where(title: k.to_s).first
      formatter = Formatter.detect(k.to_s, v)
      data_type = formatter[:data_type]
      content = formatter[:content]
      
      if field
        if field.data_type == "string" && data_type != "string"
          field.update_attributes data_type: data_type
        end
      else
        field = user.fields.create(title: k.to_s, data_type: data_type)
      end
      
      prepared_data[k.to_s] = content
    end
    
    self.data = prepared_data
  end
  
  def self.filter(requirements = [], order = "name", direction = "asc")
    queries = []
    normal_fields = ["created_at", "updated_at", "name"]

    unless normal_fields.include? order
      # cast(doc_data->'METADATA.FILEID' as int)
      order = "data -> '#{order}'"
    end
    
    if requirements.any?
      requirements.each do |field, matcher, search, args|
        search = search.to_s unless args.blank?
      
        if normal_fields.include? field
          case matcher
          when "is"
            queries.push "contacts.#{field} = '#{search}'"
          when "like"
            queries.push "contacts.#{field} ilike '%#{search}%'"
          when "greater_than"
            queries.push "contacts.#{field} > '#{search}'"
          when "less_than"
            queries.push "contacts.#{field} < '#{search}'"
          end  
        else
          case matcher
          when "is"
            queries.push "contacts.data @> '#{field}=>#{search}'"
          when "like"
            queries.push "contacts.data -> '#{field}' ilike '%#{search}%'"
          when "greater_than"
            queries.push "contacts.data -> '#{field}' > '#{search}'"
          when "less_than"
            queries.push "contacts.data -> '#{field}' < '#{search}'"
          when "recurring"
            start = args[:start]
            finish = args[:finish]
            queries.push "to_char(cast(contacts.data -> '#{field}' as date), 'MMDD') BETWEEN '#{start.strftime("%m%d")}' and '#{finish.strftime("%m%d")}'"
          end
        end
      end
      
      where(queries.join(" and ")).order("contacts.#{order} #{direction}")
    else
      order("contacts.#{order} #{direction}")
    end
  end
end
