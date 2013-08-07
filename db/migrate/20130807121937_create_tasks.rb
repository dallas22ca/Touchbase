class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.belongs_to :followup, index: true
      t.belongs_to :contact, index: true
      t.datetime :date
      t.text :content
      t.boolean :complete, default: false

      t.timestamps
    end
  end
end
