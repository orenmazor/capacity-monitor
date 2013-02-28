
namespace :newrelic do
  desc "sample metrics from newrelic"
  task :sample => [:environment] do

    puts "Syncing metrics for agents..."

    start = Time.now.utc - 20.minutes
    finish = Time.now.utc - 10.minutes

    run = Run.create(:start => start, :end => finish)

    StatsD.generate_rpm_sample(run, start, finish)

    count = 0

    fields = NewrelicMetric.uniq.pluck(:field)
    fields.each do |field|
      metrics = Metric.uniq.where(["field = ?", field]).pluck(:name)
      newrelic_ids = Metric.uniq.joins("LEFT OUTER JOIN agents ON agents.id = metrics.agent_id").where(["field = ?", field]).pluck("agents.newrelic_id")

      agents = Agent.where(:newrelic_id => newrelic_ids)

      result = []
      metrics.each_slice(10) do |slice|
        tmp = Newrelic.get_value(newrelic_ids, slice, field, start, finish) || []
        if tmp.is_a? Array
          result += tmp
        else
          puts "Newrelic returned #{tmp}, expecting array"
        end
      end

      results_by_agent = {}

      result.each do |r|
        results_by_agent[r["agent_id"].to_i] ||= []
        results_by_agent[r["agent_id"].to_i] << r
      end

      agents.each do |agent|
        if results_by_agent[agent.newrelic_id]
          agent.metrics.each do |metric|
            value = results_by_agent[agent.newrelic_id].detect { |res| res["name"] == metric.name }
            if value
              metric.create_sample(value, run)
              count +=1
            end
          end
        end
      end
    end

    $stdout.puts "Generated #{count} samples from newrelic"
  end
end
