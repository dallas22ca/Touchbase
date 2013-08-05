class AddContactsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contacts_count, :integer
  end
end
