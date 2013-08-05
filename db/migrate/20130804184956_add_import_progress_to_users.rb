class AddImportProgressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :import_progress, :integer
  end
end
