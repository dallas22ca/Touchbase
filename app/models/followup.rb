class Followup < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  serialize :criteria, Array
  
  has_many :tasks, dependent: :destroy
  
  belongs_to :user
  belongs_to :field

  before_validation :set_starting_at
  before_validation :set_criteria
  validates_presence_of :user_id, :description
  before_save :add_name_to_description, unless: Proc.new { |f| f.description.match(/\{\{name\}\}/) }
  after_save :invite_user_to_step, :sidekiq_create_tasks
  
  def set_starting_at
    if self.recurrence == 0
      self.starting_at = nil
    else
      self.starting_at = Time.zone.now if self.starting_at.blank?
      self.offset = 0
    end
  end
  
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
  
  def create_tasks(start = nil, finish = nil, search_all_contacts = false, update_all = false, create_if_needed = true)
    if remind_every?
      
      # WHAT SHOULD THIS ACTUALLY DO? :: SAME AS BELOW!
      # 2. Loop through all contacts tasks
      # 3. Try to find a task between dates.
      # 4. If not there, create it. If there, edit it.
      
    else

      start ||= Time.now
      
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
          actual_date = Chronic.parse(actual_data.in_time_zone.strftime("%B %d, #{start.year}")).beginning_of_day
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
              sub = sub.in_time_zone.strftime("%B %d") if field.data_type == "datetime"
              desc = desc.to_s.gsub(/\{\{#{field.permalink}\}\}/, sub)
            end
          
            task.date = remind_at
            task.content = desc
            task.save!
          end
        end
      end
      
    end
  end
  
  def offset_word
    if remind_every?
      "every"
    elsif remind_before?
      "before"
    elsif remind_after?
      "after"
    elsif remind_on?
      "on"
    end
  end
  
  def remind_every?
    recurrence > 0
  end
  
  def remind_before?
    offset < 0 && !remind_every?
  end
  
  def remind_on?
    offset == 0 && !remind_every?
  end
  
  def remind_after?
    offset > 0 && !remind_every?
  end
  
  def timing
    if remind_every?
      timing = distance_of_time_in_words(recurrence.seconds)
      
      if field
        "#{offset_word.capitalize} #{timing} starting on their #{field.title}"
      else
        "#{offset_word.capitalize} #{timing} starting on #{starting_at.strftime("%b %-d, %Y")}"
      end
    else
      timing = distance_of_time_in_words(offset.seconds)
    
      if remind_before?
        timing = "#{timing.capitalize} before"
      elsif remind_after?
        timing = "#{timing.capitalize} after"
      elsif remind_on?
        timing = "On"
      end
    
      if field
        "#{timing} their #{field.title}"
      else
        timing
      end
    end
  end
end
