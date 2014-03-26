class ImportWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "ImportWorker"
  
  def perform id, src, option = false
    
    if src == "blob"
      user = User.find(id)
      user.import_blob option
    elsif src == "file"
      user = User.find(id)
      user.import_file option
    elsif src == "field_update_contacts_with_data"
      field = Field.find(id)
      field.update_contacts_with_data(option) if field
    elsif src == "field_update_contacts_with_permalink"
      field = Field.find(id)
      field.update_contacts_with_permalink(option) if field
    elsif src == "followup"
      followup = Followup.find(id)
      followup.create_tasks option, 6.weeks.to_i if followup
    end
  end
end