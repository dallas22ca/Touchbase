class AddImportProgressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :import_progress, :integer, default: 100
  end
end
