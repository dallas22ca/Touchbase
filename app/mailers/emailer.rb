class Emailer < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper
  
  def bulk(user, email, contact)
    encryptor = ActiveSupport::MessageEncryptor.new(CONFIG["secret"])
    @plain = email.contactify(email.plain, contact)
    @unsubscribe = subscription_url(contact.token)

    mail({
      from: "#{user.name} <#{user.email}>", 
      to: "#{contact.name} <#{contact.data["email"]}>", 
      subject: email.contactify(email.subject, contact)
    })
  end
end
