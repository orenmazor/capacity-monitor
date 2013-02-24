
namespace :newrelic do
  desc "sample metrics from newrelic"
  task :sample => [:environment] do

    Agent.find_each do |agent|
      agent.sync_metrics
    end

    start =  Time.now.utc - 20.minutes
    finish = Time.now.utc - 10.minutes
    count = 0

    Metric.find_each do |metric|
      count += 1
      metric.generate_sample(start, finish)
    end

    $stdout.puts "Generated #{count} samples from newrelic"
  end
end
