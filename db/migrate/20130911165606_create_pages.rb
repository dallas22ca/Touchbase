class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.belongs_to :website, index: true
      t.string :title
      t.string :permalink

      t.timestamps
    end
  end
end
