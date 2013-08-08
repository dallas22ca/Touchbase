class Contact < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  
  has_many :tasks
  
  attr_accessor :overwrite, :warnings, :use_pending, :ignore_formatting
  
  validates_presence_of :user_id
  validates_uniqueness_of :name, scope: :user_id
  
  scope :pending, -> { where("pending_data is not ?", nil) }
  
  before_validation :write_pending, if: :use_pending
  before_validation :move_data_to_pending, unless: Proc.new { |c| c.overwrite? || c.new_record? }
  before_validation :set_defaults
  validate :not_duplicate_data
  before_save :format_data, unless: Proc.new { |c| c.ignore_formatting }
  after_save :create_followup_tasks, if: Proc.new { |c| [0, 100].include?(c.user.import_progress) }
    
  def set_defaults
    self.pending_data = nil if self.overwrite
    self.warnings ||= []
  end
  
  def write_pending
    self.data = pending_data
    self.overwrite = true
  end
  
  def not_duplicate_data
    d = data
    p = pending_data
    d ||= {}
    p ||= {}
    
    if !self.warnings.blank? && d == d.merge(p)
      self.errors.add :base, "#{name} is a duplicate. This data has been ignored."
    end
  end
  
  def move_data_to_pending
    pending = self.data
    self.reload
    self.warnings = ["#{name} has pending data."]
    self.pending_data = pending
  end
  
  def format_data
    prepared_data = self.data
    prepared_data = {} if d.blank?
    
    if self.original_data.nil?
      self.original_data = prepared_data
    else
      self.original_data = self.original_data.merge(prepared_data)
    end
    
    user.fields.each do |field|
      content = Formatter.format(field.data_type, prepared_data[field.permalink])
      prepared_data[field.permalink] = content
    end
    
    self.data = prepared_data unless prepared_data == {}
  end
  
  def self.filter(requirements = [], q = "", order = "name", direction = "asc", data_type = "string")
    queries = []
    normal_fields = ["created_at", "updated_at", "name"]

    unless normal_fields.include? order
      if data_type == "integer"
        order = "cast(contacts.data -> '#{order}' as numeric)"
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
          queries.push "contacts.data @> hstore('#{field}', '#{search}')"
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
  
  def create_followup_tasks
    user.followups.map { |f| f.sidekiq_create_tasks }
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
