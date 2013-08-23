class AddEmailIdToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :email, index: true
  end
end
