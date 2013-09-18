class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name
      t.text :body
      t.string :extension

      t.timestamps
    end
  end
end
