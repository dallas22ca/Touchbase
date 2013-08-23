class GenerateContactTokens < ActiveRecord::Migration
  def change
    Contact.all.find_each do |c|
      c.update_column :token, SecureRandom.hex
    end
  end
end
