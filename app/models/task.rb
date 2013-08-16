class Task < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  belongs_to :followup
  belongs_to :contact
  has_one :user, through: :contact
  
  validates_presence_of :date, :content
  
  scope :complete, -> { where(complete: true) }
  scope :incomplete, -> { where(complete: false) }
  
  before_save :set_completed_at
  
  def set_completed_at
    if complete_changed?
      if complete
        self.completed_at = Time.now
      else
        self.completed_at = nil
      end
    end
  end
  
  def content_with_links
    link = contact_url(contact.id)
    content_with_links = content.gsub("{{name}}", ActionController::Base.helpers.link_to(contact.name, link))
    
    user.fields.each do |f|
      text = f.substitute_data(contact.data[f.permalink])
      content = content.to_s.gsub(/\{\{#{f.permalink}\}\}/, text)
    end
    
    content_with_links
  end
end
