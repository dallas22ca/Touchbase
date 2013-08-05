class User < ActiveRecord::Base
  attr_accessor :overwrite
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
     
  has_many :contacts
  has_many :fields
  
  accepts_nested_attributes_for :fields, allow_destroy: true
  
  has_attached_file :file,
                    :path  => Rails.env.development? || Rails.env.test? ? "#{Rails.root}/uploads/:user_id/:hash.:extension" : "/home/deployer/apps/touchbase/shared/uploads/:user_id/:hash.:extension",
                    :url => "/uploads/:user_id/:hash.:extension",
                    :hash_secret => "R3sadkfasd8fkj8k0a8dfyh3jr23uy32r3j2j23hlk3j"
  
  Paperclip.interpolates :user_id do |file, style|
    file.instance.id
  end
  
  after_save :sidekiq_blob_import, if: :blob
  after_save :sidekiq_file_import, if: Proc.new { |u| u.file.exists? }
  
  def sidekiq_blob_import
    ImportWorker.perform_async id, "blob"
  end
  
  def sidekiq_file_import
    ImportWorker.perform_async id, "file"
  end
  
  def import_blob
    if Importer.from_blob blob.strip, id, overwrite
      self.update_attributes blob: nil, import_progress: 100
    end
  end
  
  def import_file
    if Importer.from_file file.path, id, overwrite
      self.file.clear
      self.import_progress = 100
      self.save
    end
  end
  
  def save_contact(args = {})
    name = args.delete(:name)
    c = contacts.where(name: name).first
    
    if c
      c.update_attributes args
    else
      c = contacts.create name: name, data: args[:data]
    end

    c
  end
end
