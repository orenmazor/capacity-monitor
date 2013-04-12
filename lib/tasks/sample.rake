
namespace :newrelic do

  desc "sample metrics from newrelic"
  task :sample => [:environment] do
    start = Time.now.utc - 30.minutes
    if ENV['START_TIME']
      start = Time.parse(ENV['START_TIME'])
    end

    Oracle.sample(start, start + 20.minutes)
    update_relevance
  end

  desc "backfill metrics from newrelic, use with START='1.month.ago' or similar"
  task :backfill => [:environment] do
    raise "Run with START='1.month.ago' or similar" unless ENV["START"]

    start = eval(ENV['START'])

    while start < Time.now
      Oracle.sample(start, start + 20.minutes)
      start += 1.hour
    end
    update_relevance
  end

  def update_relevance
    Metric.find_each do |metric|
      metric.update_relevance
      metric.save
    end
  end
end
