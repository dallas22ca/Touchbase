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
  
  def create_tasks(query_start = nil, query_finish = nil, contact_id = nil)
    query_start ||= Time.now
    query_finish ||= query_start.end_of_day + 30.days
    filters = []
    
    if contact_id
      tasks.incomplete.where(contact_id: contact_id).destroy_all
      filters.push ["id", "is", contact_id]
    else
      tasks.incomplete.destroy_all
      # filters = [[field.permalink, "recurring", nil, { start: start, finish: finish }]]
    end
    
    user.contacts.filter(filters).find_each do |contact|
      how_often = 1.year.to_i
      
      if field
        start = Chronic.parse(contact.data[field.permalink].to_datetime.strftime("%B %d, #{query_start.year}")).beginning_of_day
      else
        start = starting_at
      end
      
      if remind_every?
        how_often = recurrence.seconds
      else
        
        start = start + offset.seconds
      end
      
      date = query_start
      
      while date <= query_finish
        desc = description.gsub("{{name}}", contact.name)
        user.fields.map { |f| desc = desc.to_s.gsub(/\{\{#{f.permalink}\}\}/, f.substitute_data(contact.data[f.permalink])) }
      
        task = tasks.create(
          contact_id: contact.id, 
          complete: false,
          date: date,
          content: desc
        )
        
        date = date + how_often
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
