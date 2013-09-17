class AddAvailableDaysToUsers < ActiveRecord::Migration
  def change
    add_column :users, :available_days, :text
  end
end
