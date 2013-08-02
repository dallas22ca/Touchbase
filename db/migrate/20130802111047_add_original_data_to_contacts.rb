class AddOriginalDataToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :original_data, :hstore
  end
end
