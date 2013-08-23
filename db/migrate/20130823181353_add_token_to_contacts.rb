class AddTokenToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :token, :string
  end
end
