class AddDataIndexOnContacts < ActiveRecord::Migration
  def up
    execute "CREATE INDEX contacts_data ON contacts USING GIST(data)"
  end
  
  def down
    execute "DROP INDEX contacts_data"
  end
end
