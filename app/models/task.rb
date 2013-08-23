class Task < ActiveRecord::Base
  belongs_to :followup
  belongs_to :contact
  belongs_to :email
  belongs_to :user
  
  validates_presence_of :date, :content, :user_id
  
  scope :complete, -> { where(complete: true) }
  scope :incomplete, -> { where(complete: false) }
  scope :non_email, -> { where(email_id: nil) }
  
  before_validation :stop_if_has_email
  before_save :set_completed_at
  
  def stop_if_has_email
    if email && !complete
      self.errors.add :base, "This task is locked, it was not saved."
    end
  end
  
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
    content_with_links = content
    
    if contact
      content_with_links = content_with_links.gsub("{{contact.name}}", ActionController::Base.helpers.link_to(contact.name, "/contacts/#{contact_id}"))
      
      user.fields.each do |f|
        text = f.substitute_data(contact.d[f.permalink])
        content_with_links = content_with_links.to_s.gsub(/\{\{contact.#{f.permalink}\}\}/, text)
      end
    end
    
    if email
      content_with_links = content_with_links.gsub("{{email.subject}}", ActionController::Base.helpers.link_to(email.subject, "/emails/#{email_id}"))
      content_with_links = content_with_links.gsub("{{email.to}}", contact.d["email"]) if contact && contact.has_email?
      content_with_links = content_with_links.gsub("{{email.from}}", user.email)
    end
    
    content_with_links
  end
end
