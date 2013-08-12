set_default(:sidekiq_pid) { "#{current_path}/tmp/pids/sidekiq.pid" }
set_default(:sidekiq_config) { "#{current_path}/config/sidekiq.yml" }
set_default(:sidekiq_log) { "#{shared_path}/log/sidekiq.log" }