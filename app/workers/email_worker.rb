class EmailWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "EmailWorker"
  
  def perform type, id, options = {}
    if type == "prepare"
      email = Email.find id
      
      email.user.contacts.filter(email.criteria).find_each do |contact|
        EmailWorker.perform_async "send", id, { "contact_id" => contact.id }
      end
    elsif type == "send"
      email = Email.find id
      email.deliver_to(options["contact_id"])
    end
  end
end