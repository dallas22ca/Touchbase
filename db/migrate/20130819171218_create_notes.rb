class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.belongs_to :contact, index: true
      t.text :description
      t.datetime :date

      t.timestamps
    end
  end
end
