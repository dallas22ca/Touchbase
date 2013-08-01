class AddDataIndexOnContacts < ActiveRecord::Migration
  def up
    execute "CREATE INDEX contacts_data ON contacts USING GIN(data)"
  end
  
  def down
    execute "DROP INDEX contacts_data"
  end
end
