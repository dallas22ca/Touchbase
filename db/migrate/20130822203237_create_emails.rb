class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.belongs_to :user, index: true
      t.text :criteria
      t.text :subject
      t.text :plain

      t.timestamps
    end
  end
end
