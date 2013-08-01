class Field < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name, :permalink
  validates_uniqueness_of :name
  
  before_validation :set_permalink, :set_data_type
  
  def set_permalink
    self.permalink ||= name.parameterize
  end
  
  def set_data_type
    self.data_type ||= "string"
  end
end
