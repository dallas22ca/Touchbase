class Website < ActiveRecord::Base
  has_many :pages
  has_many :documents
  
  belongs_to :default_page, class_name: "Page"
end
