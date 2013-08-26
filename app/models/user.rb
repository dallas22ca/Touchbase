class User < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  
  attr_accessor :overwrite, :upload
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
     
  has_many :contacts
  has_many :notes, through: :contacts
  has_many :fields
  has_many :followups
  has_many :tasks
  has_many :emails
  
  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: Proc.new { |f| f[:title].blank? }
  
  has_attached_file :file,
                    :path  => Rails.env.development? || Rails.env.test? ? "#{Rails.root}/uploads/:user_id/:hash.:extension" : "/home/deployer/apps/touchbase/shared/uploads/:user_id/:hash.:extension",
                    :url => "/uploads/:user_id/:hash.:extension",
                    :hash_secret => "R3sadkfasd8fkj8k0a8dfyh3jr23uy32r3j2j23hlk3j"
  
  Paperclip.interpolates :user_id do |file, style|
    file.instance.id
  end
  
  validates_presence_of :address, if: Proc.new { |u| u.emails.any? }
  after_create :add_to_dallas
  before_create :generate_api_token
  before_save :set_step
  after_save :sidekiq_blob_import, if: Proc.new { |u| u.upload && !u.blob.blank? }
  after_save :sidekiq_file_import, if: Proc.new { |u| u.upload && u.file.exists? }
  
  def add_to_dallas
    dallas = User.where(email: "dallasgood@gmail.com").first
    dallas.contacts.create name: name, data: { email: email, signed_up_at: created_at } if dallas
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
  
  def import_array(array = [], args = {})
    saved_contacts = []
    args[:overwrite] ||= false
    
    array.each do |contact|
      c = save_contact contact.merge({ overwrite: args[:overwrite] })
      details = { "name" => c.name }.merge(c.d)
      saved_contacts.push details
    end
    
    { success: true, contacts: saved_contacts }
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
    args = args.stringify_keys.each_with_object({}) do |(k, v), h|
      h[k.downcase] = v
    end
    
    overwrite = args.delete("overwrite")
    overwrite ||= false
    name = args.delete("name")
    name = "#{args["first-name"]} #{args["last-name"]}" if name.blank?
    c = contacts.where(name: name).first
    
    if c
      c.update_attributes data: args, overwrite: overwrite
    else
      c = contacts.create name: name, data: args
    end

    c
  end
  
  def has_pending_import?
    file.present? || !blob.blank?
  end
  
  def has_valid_pending_import?
    (file.present? || !blob.blank?) && fields.any?
  end
  
  def has_deletable_pending_import?
    has_valid_pending_import? && [0, 100].include?(import_progress)
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
      self.import_progress = 100
      self.blob = nil
      self.file.clear
      self.save
      self.errors.add :base, "Please upload add a header row so we know how to read your data!"
      false
    else
      headers
    end
  end
  
  def tasks_for(start, finish = nil)
    unless finish
      start = start.beginning_of_day
      finish = start.end_of_day
    end
    
    tasks.where("(tasks.date BETWEEN :start and :finish and tasks.complete = :false) or (tasks.date <= :start and tasks.complete = :false) or (tasks.complete = :true and tasks.completed_at BETWEEN :start and :finish)", 
      start: start, 
      finish: finish,
      true: true,
      false: false
    ).order(:complete, :date, :completed_at)
  end
  
  def suggested_fields
    suggested_fields = []
    
    Field.suggested.each do |title, permalink, data_type|
      unless fields.pluck(:permalink).include? permalink
        suggested_fields.push link_to(title, "#", class: "add_suggested_field", data: { title: title, data_type: data_type, permalink: permalink })
      end
    end
    
    suggested_fields
  end
  
  def set_step
    if self.step < 5
      if contacts.empty?
        if !has_pending_import?
          self.step = 1
        else
          if upload
            self.step = 4
          else
            self.step = 3
          end
        end
      end
      
      if followups.any?
        self.step = 5
      end
    end
  end
  
  def allowed_actions
    actions = []
    
    if step >= 1
      actions.push "contacts\#(new|create|multicreate)"
      actions.push "sessions"
      actions.push "registrations"
      actions.push "pages\#show"
    end
    
    if step >= 3
      actions.push "fields\#(index|update)"
    end
    
    if step >= 4
      actions.push "followups"
    end
    
    if step >= 5
      actions = []
    end
    
    /#{actions.join("|")}/
  end
  
  def next_step
    router = Rails.application.routes.url_helpers
    
    if step <= 2
      router.protected_page_path("welcome")
    elsif step <= 3
      router.fields_path
    elsif step <= 4
      router.followups_path
    elsif step <= 5
      router.tasks_path
    end
  end
  
  def generate_api_token
    self.api_token = SecureRandom.urlsafe_base64(24)
  end
  
  def emailer?
    email =~ /dallas|gavin/
  end
end
