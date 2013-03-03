namespace :jobs do

  task :work => ['newrelic:fetch_servers', 'newrelic:sample'] do
  end
end
