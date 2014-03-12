class Emailer < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper
  
  def bulk(user, email, contact)
    encryptor = ActiveSupport::MessageEncryptor.new(CONFIG["secret"])
    @plain = email.contactify(email.plain, contact)
    @unsubscribe = subscription_url(contact.token)
    @address = user.address
    
    headers = {
      from: "#{user.name} <#{user.email}>", 
      to: "#{contact.name} <#{contact.data["email"]}>", 
      subject: email.contactify(email.subject, contact)
    }
    
    headers[:to] = contact.data["email"] if contact.data["email"].split(",").size > 1

    mail(headers)
  end
end
