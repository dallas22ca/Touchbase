class AddWebsiteToDocuments < ActiveRecord::Migration
  def change
    add_reference :documents, :website, index: true
  end
end
