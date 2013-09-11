class AddDefaultPageToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :default_page_id, :integer
    add_index :websites, :default_page_id
  end
end
