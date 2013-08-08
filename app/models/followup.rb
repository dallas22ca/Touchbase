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
    ImportWorker.perform_async id, "followup", offset_was
  end
  
  def create_tasks(start = Time.now, offset_was = nil)
    o_was = offset_was
    o_was = offset if o_was.nil?
    
    if field
      if remind_before?
        finish = start - o_was.seconds
        filters = [[field.permalink, "recurring", nil, { start: start, finish: finish }]]
      elsif remind_after?
        finish = start - o_was.seconds - 1.year
        filters = [[field.permalink, "recurring", nil, { start: finish.beginning_of_year, finish: finish }]]
      elsif remind_on?
        filters = [[field.permalink, "recurring", nil, { start: start, finish: start.end_of_day }]]
      end
      
      filters = [] if offset_changed?
        
      user.contacts.filter(filters).find_each do |contact|
        contact_start = contact_finish = actual_date = contact.data[field.permalink].to_datetime.beginning_of_day
        o = (contact_start - o_was.seconds).beginning_of_day
        o > contact_start ? contact_finish = o : contact_start = o
        remind_at = Chronic.parse ((contact_start + offset.seconds).beginning_of_day).strftime("%B %d, #{start.year}")
        task = tasks.where(contact_id: contact.id, complete: false).first_or_initialize
        
        if contact_start.strftime("#{start.strftime("%y")}%m%d").to_i > start.strftime("%y%m%d").to_i || contact_start.strftime("#{start.strftime("%y")}%m%d").to_i > finish.strftime("%y%m%d").to_i
          task.date = remind_at
          task.content = description.gsub("{{name}}", contact.name).gsub("{{date}}", actual_date.strftime("%B %d"))
          task.save!
        else
          task.destroy
        end
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
