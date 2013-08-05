class Field < ActiveRecord::Base
  belongs_to :user
  
  before_validation :set_permalink, :set_data_type
  
  validates_presence_of :title, :permalink
  validates_uniqueness_of :permalink, scope: :user_id
  validates_uniqueness_of :title, scope: :user_id
  
  after_update :sidekiq_update_contacts
  
  def set_permalink
    self.permalink = self.title.parameterize if self.permalink.blank?
  end
  
  def set_data_type
    self.data_type = "string" if self.data_type.blank?
  end
  
  def sidekiq_update_contacts
    ImportWorker.perform_async id, "field"
  end
  
  def update_contacts
    user.contacts.find_each do |contact|
      content = contact.original_data[field.permalink]
      contact.data[field.permalink] = Formatter.format(data_type, content)
      contact.overwrite = true
      contact.save
    end
  end
end
