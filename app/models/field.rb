class Field < ActiveRecord::Base
  has_many :followups
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
    ImportWorker.perform_async id, "field"
  end
  
  def update_contacts
    user.contacts.find_each do |contact|
      content = contact.original_data[permalink]
      details = { permalink => Formatter.format(data_type, content) }
      contact.data = contact.data.merge(details)
      contact.ignore_formatting = true
      contact.overwrite = true
      contact.save
    end
  end
end
