class Followup < ActiveRecord::Base
  serialize :criteria, Array
  
  has_many :tasks
  
  belongs_to :user
  belongs_to :field
  
  validates_presence_of :user_id, :description
  
  before_save :add_name_to_description, unless: Proc.new { |f| f.description.match(/\{\{name\}\}/) }
  
  def add_name_to_description
    self.description = "#{self.description} to {{name}}"
  end
  
  def generate_tasks(time = Time.now)
    if field
      if offset < 0
        start = time
        finish = start - offset
        filters = [[field.permalink, "recurring", nil, { start: start, finish: finish }]]
        remind_at = finish
      else
        start = time
        finish = time - offset - 1.year
        filters = [[field.permalink, "recurring", nil, { start: finish.beginning_of_year, finish: finish }]]
        remind_at = start
      end
        
      user.contacts.filter(filters).find_each do |contact|
        start = contact.data[field.permalink].to_datetime
        finish = contact.data[field.permalink].to_datetime - offset
        contact_tasks = tasks.where(contact_id: contact.id, date: start..finish)
      
        if contact_tasks.any?
          task = contact_tasks.first
        else
          task = tasks.new(contact_id: contact.id, date: remind_at)
        end
      
        task.content = description.gsub("{{name}}", contact.name)
        task.save!
      end
    else
    end
  end
end
