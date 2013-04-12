
namespace :newrelic do

  desc "sample metrics from newrelic"
  task :sample => [:environment] do
    start = Time.now.utc - 30.minutes
    if ENV['START_TIME']
      start = Time.parse(ENV['START_TIME'])
    end

    sample(start, start + 20.minutes)
    update_relevance
  end

  desc "backfill metrics from newrelic, use with START='1.month.ago' or similar"
  task :backfill => [:environment] do
    raise "Run with START='1.month.ago' or similar" unless ENV["START"]

    start = eval(ENV['START'])

    while start < Time.now
      sample(start, start + 20.minutes)
      start += 1.hour
    end
    update_relevance
  end

  def sample(start, finish)
    newrelic_rpm = Newrelic.get_value(Newrelic.application.id, "HttpDispatcher", "requests_per_minute", start.iso8601(0), finish.iso8601(0))[0]["requests_per_minute"]

    puts "Sampling #{start}, RPM from NewRelic=#{newrelic_rpm}"
    if newrelic_rpm == 0
      puts "Newrelic RPM = 0, skipping."
      return
    end

    run = Run.create(:begin => start, :end => finish)
    puts "Sampling for run #{run.id}"
    FactSample.create(:run => run, :value => newrelic_rpm)

    count = 0

    fields = NewrelicMetric.uniq.pluck(:field)
    fields.each do |field|
      metrics = Metric.uniq.where(["field = ?", field]).pluck(:name)
      newrelic_ids = Metric.uniq.joins("LEFT OUTER JOIN agents ON agents.id = metrics.agent_id").where(["field = ?", field]).pluck("agents.newrelic_id")

      puts "Calling NewRelic with #{metrics.count} for #{field}"

      agents = Agent.where(:newrelic_id => newrelic_ids)

      result = []
      metrics.each_slice(40) do |metric_slice|
        newrelic_ids.each_slice(40) do |id_slice|
          print "."
          tmp = Newrelic.get_value(id_slice, metric_slice, field, start.iso8601(0), finish.iso8601(0))
          if tmp.is_a? Array
            result += tmp
          else
            puts "Newrelic returned #{tmp}, expecting array"
          end
        end
      end

      results_by_agent = {}

      result.each do |r|
        next if r["value"] == 0
        results_by_agent[r["agent_id"].to_i] ||= []
        results_by_agent[r["agent_id"].to_i] << r
      end

      agents.each do |agent|
        if results_by_agent[agent.newrelic_id]
          agent.metrics.each do |metric|
            raw = results_by_agent[agent.newrelic_id].detect { |res| res["name"] == metric.name }
            if raw
              m = metric.metric_samples.new
              m.run = run
              m.value = raw[field]
              count +=1
            end
          end
        else
          puts "No results for agent #{agent.hostname}"
        end
      end
    end

    $stdout.puts "Generated #{count} samples from newrelic"

  end

  def update_relevance
    Metric.find_each do |metric|
      metric.update_relevance
      metric.save
    end
  end
end
