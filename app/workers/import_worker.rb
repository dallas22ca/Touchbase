class ImportWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "ImportWorker"
  
  def perform user_id, src
    if src == "blob"
      user = User.find(user_id)
      user.import_blob
    elsif src == "file"
      user = User.find(user_id)
      user.import_file
    end
  end
end