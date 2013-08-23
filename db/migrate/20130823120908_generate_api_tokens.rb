class GenerateApiTokens < ActiveRecord::Migration
  def change
    User.all.find_each do |u|
      u.generate_api_token
      u.save!
    end
  end
end
