require "bundler/capistrano"
require 'sidekiq/capistrano'

Dir.glob("config/recipes/*.rb").each do |file|
  load file
end

set :application, "touchbase"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :workers, { '*' => 3 }

set :scm, "git"
set :repository, "git@github.com:dallas22ca/#{application}.git"

set :maintenance_template_path, File.expand_path("../recipes/templates/maintenance.html.erb", __FILE__)
set :whenever_command, "bundle exec whenever"

set :server_name, "66.228.40.130"
set :rails_env, "production"
set :branch, "master"
set :root_url, "http://touchbasenow.com"
server server_name, :web, :app, :db, primary: true

# set :sidekiq_cmd, "RAILS_ENV=#{rails_env} bundle exec sidekiq -q ListParser,1 -q DesignCapturer,1 -q MessageEnqueuer,1 -q WebhookHitter,1 -q BulkSender,1 -q ApiSender,1 -q ApiHitter,1"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:migrate"
after "deploy", "deploy:cleanup"
after "deploy:install", "deploy:autoremove"