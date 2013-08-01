class AddPendingDataToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :pending_data, :hstore
  end
end
