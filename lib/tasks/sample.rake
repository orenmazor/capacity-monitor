
namespace :newrelic do
  desc "sample metrics from newrelic"
  task :sample => [:environment] do

    start = Time.now.utc - 20.minutes
    finish = Time.now.utc - 10.minutes

    run = Run.create(:begin => start, :end => finish)

    rpm = StatsD.get_rpm_average(start, finish)

    puts "run #{run.id}, rpm from StatsD = #{rpm}"

    FactSample.create(:run => run, :value => rpm)

    count = 0

    fields = NewrelicMetric.uniq.pluck(:field)
    fields.each do |field|
      metrics = Metric.uniq.where(["field = ?", field]).pluck(:name)
      newrelic_ids = Metric.uniq.joins("LEFT OUTER JOIN agents ON agents.id = metrics.agent_id").where(["field = ?", field]).pluck("agents.newrelic_id")

      puts "Calling NewRelic with #{metrics.count} for #{field}"

      agents = Agent.where(:newrelic_id => newrelic_ids)

      result = []
      metrics.each_slice(10) do |slice|
        puts "."
        tmp = Newrelic.get_value(newrelic_ids, slice, field, start.iso8601(0), finish.iso8601(0))
        if tmp.is_a? Array
          result += tmp
        else
          puts "Newrelic returned #{tmp}, expecting array"
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
              metric.metric_samples.create(:value => raw[field], :run => run)
              count +=1
            end
          end
        end
      end
    end

    $stdout.puts "Generated #{count} samples from newrelic"
  end
end
