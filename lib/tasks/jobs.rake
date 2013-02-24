namespace :jobs do

  task :work => ['newrelic:fetch_servers'] do
  end
end
