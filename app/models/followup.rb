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
  
  def create_tasks(start = Time.now, finish = nil, search_all_tasks = false, delete_old_tasks = false)
    if field
      if finish.nil?
        if remind_before?
          finish = start - offset.seconds
        elsif remind_after?
          finish = start
          start = start - offset.seconds
        elsif remind_on?
          finish = start.end_of_day
        end
      end
      
      if search_all_tasks || offset_changed?
        filters = []
      else
        filters = [[field.permalink, "recurring", nil, { start: start, finish: finish }]]
      end
        
      user.contacts.filter(filters).find_each do |contact|
        contact_start = contact_finish = actual_date = contact.data[field.permalink].to_datetime.beginning_of_day
        o = (contact_start - offset.seconds).beginning_of_day
        o > contact_start ? contact_finish = o : contact_start = o
        remind_at = Chronic.parse ((actual_date + offset.seconds).beginning_of_day).strftime("%B %d, #{start.year}")
        task = tasks.where(contact_id: contact.id, complete: false).first_or_initialize
        
        if !delete_old_tasks || contact_start.strftime("#{start.strftime("%y")}%m%d").to_i > start.strftime("%y%m%d").to_i || contact_start.strftime("#{start.strftime("%y")}%m%d").to_i > finish.strftime("%y%m%d").to_i
          desc = description.gsub("{{name}}", contact.name)
          
          user.fields.each do |field|
            sub = contact.data[field.permalink]
            sub = sub.to_datetime.strftime("%B %d") if field.data_type == "datetime"
            desc = desc.gsub(/\{\{#{field.permalink}\}\}/, sub)
          end
          
          task.date = remind_at
          task.content = desc
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
