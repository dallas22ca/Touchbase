class Websiteship < ActiveRecord::Base
  belongs_to :website
  belongs_to :user
  
  validates_presence_of :website_id
  validates_presence_of :user_id
end
