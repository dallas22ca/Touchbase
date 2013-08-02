class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.belongs_to :user, index: true
      t.string :title
      t.string :permalink
      t.string :data_type

      t.timestamps
    end
  end
end
