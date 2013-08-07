class Task < ActiveRecord::Base
  belongs_to :followup
  belongs_to :contact
  
  validates_presence_of :date, :content
  
  scope :complete, -> { where(complete: true) }
  scope :incomplete, -> { where(complete: true) }
end
