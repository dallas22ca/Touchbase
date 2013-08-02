class Field < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :title, :permalink
  validates_uniqueness_of :title
  
  before_validation :set_permalink, :set_data_type
  
  def set_permalink
    self.permalink ||= self.title.parameterize
  end
  
  def set_data_type
    self.data_type ||= "string"
  end
end
