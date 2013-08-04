class Field < ActiveRecord::Base
  belongs_to :user
  
  before_validation :set_permalink, :set_data_type
  
  validates_presence_of :title, :permalink
  validates_uniqueness_of :title
  validates_uniqueness_of :permalink, scope: :user_id
  
  def set_permalink
    self.permalink = self.title.parameterize if self.permalink.blank?
  end
  
  def set_data_type
    self.data_type = "string" if self.data_type.blank?
  end
end
