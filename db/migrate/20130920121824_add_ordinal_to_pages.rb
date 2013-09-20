class AddOrdinalToPages < ActiveRecord::Migration
  def change
    add_column :pages, :ordinal, :integer, default: 99999
  end
end
