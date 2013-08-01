class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.string :permalink
      t.string :data_type

      t.timestamps
    end
  end
end
