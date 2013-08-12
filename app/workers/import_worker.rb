class ImportWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "ImportWorker"
  
  def perform id, src, overwrite = false
    
    if src == "blob"
      user = User.find(id)
      user.import_blob overwrite
    elsif src == "file"
      user = User.find(id)
      user.import_file overwrite
    elsif src == "field"
      field = Field.find(id)
      field.update_contacts if field
    elsif src == "followup"
      followup = Followup.find(id)
      
      if followup
        Time.zone = followup.user.time_zone
        followup.create_tasks(Time.now, nil, true, true, true)
      end
    end
  end
end