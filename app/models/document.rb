class Document < ActiveRecord::Base
  belongs_to :website
  
  scope :html, -> { where(extension: "html") }
  scope :css, -> { where(extension: "html") }
  scope :js, -> { where(extension: "html") }
  
  def filename
    "#{name}.#{extension}"
  end
end
