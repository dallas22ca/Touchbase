class Emailer < ActionMailer::Base
  def bulk(user, email, contact)
    @plain = email.contactify(email.plain, contact)
    
    mail({
      from: "#{user.name} <#{user.email}>", 
      to: "#{contact.name} <#{contact.data["email"]}>", 
      subject: email.contactify(email.subject, contact)
    })
  end
end
