class Followup < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
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
  
  def create_tasks(start = Time.now, finish = nil, search_all_contacts = false, update_all = false, create_if_needed = true)
    Time.zone = user.time_zone
    
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
      
      if search_all_contacts || offset_changed?
        filters = []
      else
        filters = [[field.permalink, "recurring", nil, { start: start, finish: finish }]]
      end
        
      user.contacts.filter(filters).find_each do |contact|
        actual_data = contact.data[field.permalink]
        
        unless actual_data.blank?
          actual_date = Chronic.parse(actual_data.to_datetime.strftime("%B %d, #{start.year}")).beginning_of_day
          remind_at = actual_date + offset.seconds
          
          if update_all && !create_if_needed
            task = tasks.where(contact_id: contact.id, complete: false).first
          elsif actual_date > start
            task = tasks.where(contact_id: contact.id, complete: false).first_or_initialize
          end
          
          if task
            desc = description.gsub("{{name}}", contact.name)
          
            user.fields.each do |field|
              sub = contact.data[field.permalink]
              sub = sub.to_datetime.strftime("%B %d") if field.data_type == "datetime"
              desc = desc.to_s.gsub(/\{\{#{field.permalink}\}\}/, sub)
            end
          
            task.date = remind_at
            task.content = desc
            task.save!
          end
        end
      end
    else
    end
  end
  
  def offset_word
    if remind_before?
      "before"
    elsif remind_after?
      "after"
    elsif remind_on?
      "on"
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
  
  def timing
    if recurring
      timing = distance_of_time_in_words(offset.seconds)
    
      if remind_before? || remind_after?
        timing = "#{timing.capitalize} #{offset_word}"
      elsif remind_on?
        timing = offset_word.capitalize
      end
    
      if field
        "#{timing} their #{field.title}"
      else
        timing
      end
    else
      "Never"
    end
  end
end
