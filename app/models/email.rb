class Email < ActiveRecord::Base
  serialize :criteria, Array
  
  belongs_to :user
  
  validates_presence_of :subject, :plain, :user_id
  
  def prepare_to_deliver
    EmailWorker.perform_async "prepare", id
  end
  
  def deliver_to(contact_id)
    contact = user.contacts.find(contact_id)
    Emailer.bulk(user, self, contact).deliver if contact && contact.has_email?
  end
  
  def contactify(content, contact_id)
    contact = user.contacts.find(contact_id)
    content = content.gsub("{{name}}", contact.name)
  
    user.fields.each do |f|
      text = f.substitute_data(contact.data[f.permalink])
      content = content.to_s.gsub(/\{\{#{f.permalink}\}\}/, text)
    end
  
    content
  end
end
