class Emailer < ActionMailer::Base
  def bulk(user, email, contact)
    @plain = email.contactify(email.plain, contact.id)
    mail from: user.email, to: contact.data["email"], subject: email.contactify(email.subject, contact.id)
  end
end
