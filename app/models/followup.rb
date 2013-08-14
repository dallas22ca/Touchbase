class Followup < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  serialize :criteria, Array
  
  has_many :tasks, dependent: :destroy
  has_many :contacts, through: :tasks
  
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
  
  def sidekiq_create_tasks(contact_id = false)
    ImportWorker.perform_async id, "followup", contact_id
  end
  
  def create_tasks(contact_id = false, query_duration = 30.days.to_i, query_start = nil)
    query_start ||= Time.now.beginning_of_day
    query_start += offset
    query_finish = query_start.end_of_day + query_duration.seconds
    filters = []
    
    if contact_id
      tasks.incomplete.where(contact_id: contact_id).destroy_all
      filters.push ["id", "is", contact_id]
    else
      tasks.incomplete.destroy_all
    end
    
    user.contacts.filter(filters).find_each do |contact|
      start = false
      
      if field
        begin
          start = Chronic.parse(contact.data[field.permalink].to_datetime.strftime("%B %d, #{query_start.year}")).beginning_of_day
        rescue
        end
      else
        start = starting_at
      end
      
      if start
        if remind_every?
          how_often = recurrence.seconds
        else
          how_often = 1.year.to_i
          start = start + offset.seconds
        end
      
        date = start
      
        while date <= query_finish
          if date >= query_start
            desc = description.gsub("{{name}}", contact.name)
            user.fields.map { |f| desc = desc.to_s.gsub(/\{\{#{f.permalink}\}\}/, f.substitute_data(contact.data[f.permalink])) }
          
            if tasks.where(contact_id: contact.id, date: date).empty?
              task = tasks.create(
                contact_id: contact.id, 
                complete: false,
                date: date,
                content: desc
              )
            end
          end
        
          date = date + how_often
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
