ENV["RAILS_ENV"] ||= "production"

set :output, "/home/deployer/apps/touchbase/current/log/cron.log"

every :day, at: "11:00 PM" do
  runner "Followup.create_tasks_for_all"
end

# every 3.minutes do