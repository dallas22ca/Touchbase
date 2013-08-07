class User < ActiveRecord::Base
  attr_accessor :overwrite, :upload
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
     
  has_many :contacts
  has_many :fields
  has_many :followups
  has_many :tasks, through: :followups
  
  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: Proc.new { |f| f[:title].blank? }
  accepts_nested_attributes_for :followups, allow_destroy: true, reject_if: Proc.new { |f| f[:description].blank? }
  
  has_attached_file :file,
                    :path  => Rails.env.development? || Rails.env.test? ? "#{Rails.root}/uploads/:user_id/:hash.:extension" : "/home/deployer/apps/touchbase/shared/uploads/:user_id/:hash.:extension",
                    :url => "/uploads/:user_id/:hash.:extension",
                    :hash_secret => "R3sadkfasd8fkj8k0a8dfyh3jr23uy32r3j2j23hlk3j"
  
  Paperclip.interpolates :user_id do |file, style|
    file.instance.id
  end

  before_save :set_step
  after_save :sidekiq_blob_import, if: Proc.new { |u| u.upload && !u.blob.blank? }
  after_save :sidekiq_file_import, if: Proc.new { |u| u.upload && u.file.exists? }
  
  def set_step
    if !has_pending_import? && contacts.empty? && import_progress == 100
      self.step = 1
    elsif has_pending_import? && contacts.empty? && import_progress == 100 && fields.empty?
      self.step = 2
    elsif followups.empty?
      self.step = 3
    elsif tasks.empty?
      self.step = 4
    else
      self.step = 5
    end
  end
  
  def sidekiq_blob_import
    if self.update_column :import_progress, 0
      ImportWorker.perform_async id, "blob", overwrite
    end
  end
  
  def sidekiq_file_import
    if self.update_column :import_progress, 0
      ImportWorker.perform_async id, "file", overwrite
    end
  end
  
  def import_blob(overwrite)
    i = Importer.new(id, "blob", overwrite)
    self.update_column :import_progress, 0
    
    if i.import
      self.blob = nil
      self.import_progress = 100
      self.save
      self.followups.map { |f| f.sidekiq_create_tasks }
      i.delete_file
    end
  end
  
  def import_file(overwrite)
    i = Importer.new(id, "file", overwrite)
    self.update_column :import_progress, 0
    
    if i.import
      self.file.clear
      self.import_progress = 100
      self.save
      self.followups.map { |f| f.sidekiq_create_tasks }
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
  
  def has_pending_import?
    file.present? || !blob.blank?
  end
  
  def import_blob_headers
    h = []
    
    if has_pending_import?
      unless blob.blank?
        
        i = Importer.new(id, "blob")
        
        if i.headers
          h = i.headers
          i.create_headers
        end
        
        i.delete_file
      end
    end
    
    h
  end
  
  def import_file_headers
    h = []
    
    if has_pending_import?
      if file.exists?
        i = Importer.new(id, "file")
        
        if i.headers
          h = i.headers
          i.create_headers
        end
      end
    end
    
    h
  end
  
  def create_headers
    headers = import_blob_headers + import_file_headers
    
    if headers.empty?
      self.file.clear
      self.save
      self.errors.add :base, "Please upload a file with a header so we know how to read your data!"
    else
      false
    end
  end
  
  def tasks_for(start, finish = nil)
    unless finish
      start = start.beginning_of_day
      finish = start.end_of_day
    end
    
    tasks.where("(tasks.date BETWEEN :start and :finish) or (tasks.date <= :start and tasks.complete = :complete)", 
      start: start, 
      finish: finish,
      complete: false
    )
  end
end
