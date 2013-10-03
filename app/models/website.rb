class Website < ActiveRecord::Base
  has_many :pages, dependent: :destroy
  has_many :documents
  has_many :websiteships, dependent: :destroy
  has_many :users, through: :websiteships
  
  belongs_to :default_page, class_name: "Page"
  
  accepts_nested_attributes_for :users
  
  validates_uniqueness_of :permalink
  
  after_create :add_content
  
  def add_content
    home = self.pages.create!(
      title: "Welcome",
      permalink: "welcome",
      ordinal: 0,
      deleteable: false,
      document_id: Document.first.id
    )
    
    signin = self.pages.create!(
      title: "Sign In",
      permalink: "signin",
      ordinal: 999998,
      visible: false,
      deleteable: false,
      document_id: Document.first.id
    )
    
    sitemap = self.pages.create!(
      title: "Sitemap",
      permalink: "sitemap",
      ordinal: 999999,
      visible: false,
      deleteable: false,
      document_id: Document.first.id
    )
    
    self.update_column :default_page_id, home.id
  end
end
