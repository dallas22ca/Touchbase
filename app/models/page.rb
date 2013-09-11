class Page < ActiveRecord::Base
  belongs_to :website
  
  validates_presence_of :title, :permalink
  
  before_save :parameterize_permalink, if: :permalink_changed?
  
  def parameterize_permalink
    self.permalink = self.permalink.parameterize
  end
end
