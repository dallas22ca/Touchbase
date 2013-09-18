class Page < ActiveRecord::Base
  belongs_to :website
  belongs_to :layout, class_name: "Document", foreign_key: "document_id"
  
  belongs_to :parent, class_name: "Page", primary_key: "parent_id"
  has_many :children, class_name: "Page", foreign_key: "parent_id"
  
  validates_presence_of :title, :permalink, :document_id
  
  before_save :parameterize_permalink, if: :permalink_changed?
  
  scope :roots, -> { where(parent_id: nil) }
  
  def parameterize_permalink
    self.permalink = self.permalink.parameterize
  end
  
  def siblings
    website.pages.where(parent_id: parent_id)
  end
  
  def root?
    parent_id == nil
  end
end
