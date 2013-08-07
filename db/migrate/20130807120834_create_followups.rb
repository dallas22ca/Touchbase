class CreateFollowups < ActiveRecord::Migration
  def change
    create_table :followups do |t|
      t.belongs_to :user, index: true
      t.text :criteria
      t.text :description
      t.belongs_to :field, index: true
      t.datetime :starting_at
      t.integer :offset, default: 0
      t.integer :recurrence, default: 0
      t.boolean :recurring, default: true

      t.timestamps
    end
  end
end
