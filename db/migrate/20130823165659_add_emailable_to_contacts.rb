class AddEmailableToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :emailable, :boolean, default: true
  end
end
