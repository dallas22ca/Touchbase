class AddVisibileToPages < ActiveRecord::Migration
  def change
    add_column :pages, :visible, :boolean, default: true
  end
end
