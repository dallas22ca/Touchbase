class AddOrdinalToFields < ActiveRecord::Migration
  def change
    add_column :fields, :ordinal, :integer
    add_column :fields, :show, :boolean, default: true
  end
end
