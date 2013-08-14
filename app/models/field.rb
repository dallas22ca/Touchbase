class Field < ActiveRecord::Base
  has_many :followups, dependent: :destroy
  belongs_to :user
  
  before_validation :set_permalink, :set_data_type
  
  validates_presence_of :title, :permalink
  validates_uniqueness_of :permalink, scope: :user_id
  validates_uniqueness_of :title, scope: :user_id
  
  after_save :sidekiq_update_contacts
  
  def set_permalink
    self.permalink = self.title.parameterize if self.permalink.blank?
    self.permalink = self.permalink.parameterize
  end
  
  def set_data_type
    self.data_type = "string" if self.data_type.blank?
  end
  
  def sidekiq_update_contacts
    if data_type_changed? && permalink_changed?
      ImportWorker.perform_async id, "field_update_contacts_with_data", permalink_was
    elsif data_type_changed?
      ImportWorker.perform_async id, "field_update_contacts_with_data"
    elsif permalink_changed?
      ImportWorker.perform_async id, "field_update_contacts_with_permalink", permalink_was
    end
  end

  def update_contacts_with_permalink(permalink_was)
    user.contacts.find_each do |contact|
      detail = {}
      detail[permalink] = contact.data[permalink_was]
      contact.data ||= {}
      contact.data = contact.data.merge(detail)
      contact.data.delete(permalink_was)
      contact.overwrite = true
      contact.save
    end
  end
  
  
  def update_contacts_with_data(permalink_was = false)
    user.contacts.find_each do |contact|
      contact.original_data ||= {}
      content = contact.original_data[permalink]
      details = { permalink => Formatter.format(data_type, content) }
      contact.data = contact.data.merge(details)
      contact.ignore_formatting = true
      contact.overwrite = true
      contact.save
    end
    
    ImportWorker.perform_async id, "field_update_contacts_with_permalink", permalink_was if permalink_was
  end
  
  def substitute_data(content)
    if !content.blank? && data_type == "datetime"
      content = Formatter.format(data_type, content.to_s).strftime("%B %-d")
    end
    
    content.to_s
  end
  
  def self.for_filters
    for_filters = {}
    for_filters["name"] = { "permalink" => "name", "data_type" => "string", "title" => "Name" }
    where("data_type != ?", "datetime").map{ |f| for_filters[f.permalink] = { permalink: f.permalink, data_type: f.data_type, title: f.title } }
    for_filters
  end
end
