class Note < ActiveRecord::Base
  belongs_to :contact
  
  validates_presence_of :contact_id, :date
  
  default_scope -> { order("notes.date desc") }
end
