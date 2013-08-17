class Task < ActiveRecord::Base
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
  
  def content_with_links(link)
    content_with_links = content.gsub("{{name}}", ActionController::Base.helpers.link_to(contact.name, link))
    
    user.fields.each do |f|
      text = f.substitute_data(contact.data[f.permalink])
      content_with_links = content_with_links.to_s.gsub(/\{\{#{f.permalink}\}\}/, text)
    end
    
    content_with_links
  end
end
