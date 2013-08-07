class Followup < ActiveRecord::Base
  serialize :criteria, Array
  
  has_many :tasks, dependent: :destroy
  
  belongs_to :user
  belongs_to :field
  
  before_validation :set_criteria
  validates_presence_of :user_id, :description
  before_save :add_name_to_description, unless: Proc.new { |f| f.description.match(/\{\{name\}\}/) }
  after_save :invite_user_to_step, :sidekiq_create_tasks
  
  def invite_user_to_step
    user.update_attributes updated_at: Time.now
  end
  
  def set_criteria
    self.criteria = [] unless self.criteria.kind_of?(Array)
  end
  
  def add_name_to_description
    self.description = "#{self.description} to {{name}}"
  end
  
  def sidekiq_create_tasks
    ImportWorker.perform_async id, "followup"
  end
  
  def create_tasks(time = Time.now)
    o_was = offset_was
    o_was = offset if o_was.nil?
    
    if field
      if remind_before?
        start = time
        finish = (start - o_was.seconds)
        filters = [[field.permalink, "recurring", nil, { start: start, finish: finish }]]
      elsif remind_after?
        start = time
        finish = time - o_was.seconds - 1.year
        filters = [[field.permalink, "recurring", nil, { start: finish.beginning_of_year, finish: finish }]]
      elsif remind_on?
        start = time
        filters = [[field.permalink, "recurring", nil, { start: time, finish: time.end_of_day }]]
      end
      
      filters = [] if offset_changed?
        
      user.contacts.filter(filters).find_each do |contact|
        start = contact.data[field.permalink].to_datetime
        finish = start - offset
        remind_at = Chronic.parse (start + offset.to_i.seconds).strftime("%B %d, #{time.year}")
        task = tasks.where(contact_id: contact.id, date: start..finish).first_or_initialize
        task.date = remind_at
        task.content = description.gsub("{{name}}", contact.name)
        task.save!
      end
    else
    end
  end
  
  def remind_before?
    offset < 0
  end
  
  def remind_on?
    offset == 0
  end
  
  def remind_after?
    offset > 0
  end
end
