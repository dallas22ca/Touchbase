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
      field.update_contacts
    end
  end
end