class AddBlobToUsers < ActiveRecord::Migration
  def change
    add_column :users, :blob, :text
  end
end
