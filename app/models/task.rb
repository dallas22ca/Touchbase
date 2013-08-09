class Task < ActiveRecord::Base
  belongs_to :followup
  belongs_to :contact
  
  validates_presence_of :date, :content
  
  scope :complete, -> { where(complete: true) }
  scope :incomplete, -> { where(complete: false) }
  
  before_save :set_completed_at
  
  def set_completed_at
    if complete_changed?
      if complete
        self.completed_at = Time.now
      else
        self.completed_at = nil
      end
    end
  end
end
