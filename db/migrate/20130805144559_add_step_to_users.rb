class AddStepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :step, :integer, default: 1
  end
end
