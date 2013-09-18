class AddParentToPages < ActiveRecord::Migration
  def change
    add_reference :pages, :parent, index: true
  end
end
