class CreateWebsiteships < ActiveRecord::Migration
  def change
    create_table :websiteships do |t|
      t.belongs_to :website, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
