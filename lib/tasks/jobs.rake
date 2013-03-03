namespace :jobs do

  task :work => ['newrelic:fetch_servers', 'newrelic:sample', 'predictions:predict'] do
  end
end
