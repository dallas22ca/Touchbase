class Document < ActiveRecord::Base
  belongs_to :website
  
  scope :html, -> { where(extension: "html") }
  scope :css, -> { where(extension: "css") }
  scope :js, -> { where(extension: "js") }
  
  def filename
    "#{name}.#{extension}"
  end
end
