class Email < ActiveRecord::Base
  serialize :criteria, Array
  
  attr_accessor :contact_id
  
  has_many :tasks
  has_many :contacts, through: :tasks
  belongs_to :user
  
  validates_presence_of :subject, :plain, :user_id
  validate :user_has_address, if: Proc.new { |e| e.user.address.blank? }
  
  before_validation :set_scope_for_email_to_one, unless: Proc.new { contact_id.blank? }
  after_save :prepare_to_deliver
  
  def set_scope_for_email_to_one
    c = user.contacts.find(contact_id)

    if c
      self.criteria = [["id", "is", contact_id]]
    else
      self.errors.add :base, "This contact is not accessible to you."
    end
  end
  
  def user_has_address
    self.errors.add :base, "Spam laws (CAN-SPAM) require you to include your address in your email. Visit the \"My Account\" page to update your address."
  end
  
  def prepare_to_deliver
    EmailWorker.perform_async "prepare", id
  end
  
  def deliver_to(contact_id)
    contact = user.contacts.find(contact_id)
    
    if Emailer.bulk(user, self, contact).deliver
      tasks.create(
        date: Time.now, 
        content: "Delivered \"{{email.subject}}\" email to {{contact.name}}", 
        complete: true,
        user_id: user_id,
        contact_id: contact_id
      )
    end
  end
  
  def contactify(content, contact)
    content = content.gsub("{{contact.name}}", contact.name)
  
    user.fields.each do |f|
      text = f.substitute_data(contact.data[f.permalink])
      content = content.to_s.gsub(/\{\{contact.#{f.permalink}\}\}/, text)
    end
  
    content
  end
end
