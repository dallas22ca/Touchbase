class AddAttachmentFileToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :file
    end
  end

  def self.down
    drop_attached_file :users, :file
  end
end
