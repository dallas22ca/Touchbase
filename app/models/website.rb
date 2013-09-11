class Website < ActiveRecord::Base
  has_many :pages
  has_one :default_page, class_name: "Page"
end
