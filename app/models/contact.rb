class Contact < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :overwrite, :warnings
  
  validates_presence_of :user_id
  validates_uniqueness_of :name, scope: :user_id
  
  scope :pending, -> { where("pending_data is not ?", nil) }
  
  before_validation :move_data_to_pending, unless: Proc.new { |c| c.overwrite? || c.new_record? }
  before_validation :set_defaults
  before_save :format_data
    
  def set_defaults
    self.pending_data = nil if self.overwrite
    self.warnings ||= []
  end
  
  def ignore_pending_data
    update_attributes pending_data: nil, overwrite: true
  end
  
  def write_pending_data
    update_attributes data: pending_data, pending_data: nil, overwrite: true
  end
  
  def move_data_to_pending
    pending = self.data
    self.reload
    self.warnings = ["#{name} has pending data."]
    self.pending_data = pending
  end
  
  def format_data
    if self.original_data.nil?
      self.original_data = self.data
    elsif !self.data.nil?
      self.original_data = self.original_data.merge(self.data)
    end
    
    prepared_data = {}
    d = self.data
    d = {} if self.data.blank?
    
    d.each do |k, v|
      formatter = Formatter.detect(k.to_s, v)
      data_type = formatter[:data_type]
      content = formatter[:content]
      
      if data_type != "string"
        field = user.fields.where(permalink: k.to_s).first_or_create
        field.update_attributes data_type: data_type
      end
      
      prepared_data[k.to_s] = content
    end
    
    self.data = prepared_data unless prepared_data == {}
  end
  
  def self.filter(requirements = [], q = "", order = "name", direction = "asc", data_type = "string")
    queries = []
    normal_fields = ["created_at", "updated_at", "name"]

    unless normal_fields.include? order
      if data_type == "integer"
        order = "cast(contacts.data -> '#{order}' as int)"
      else
        order = "contacts.data -> '#{order}'"
      end
    else
      order = "contacts.#{order}"
    end
    
    unless q.blank?
      q = q.to_s
      queries.push "contacts.name ilike '%#{q}%'"
    end
    
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
      
    if queries.any?
      where(queries.join(" and ")).order("#{order} #{direction}")
    else
      order("#{order} #{direction}")
    end
  end
  
  def overwrite?
    overwrite
  end
  
  def pending?
    self.pending_data != nil
  end
  
  def d
    data ? data : {}
  end
end
