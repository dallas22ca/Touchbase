class AddDeleteableToPages < ActiveRecord::Migration
  def change
    add_column :pages, :deleteable, :boolean, default: true
  end
end
