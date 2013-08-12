namespace :db do
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
end

namespace :unduplicator do
  task :remove_duplicates do
    run "cd #{current_path}; script/unduplicator"
  end
end