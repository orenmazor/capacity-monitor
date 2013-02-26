
namespace :newrelic do
  desc "sample metrics from newrelic"
  task :sample => [:environment] do

    puts "Syncing metrics for agents..."

    # get application-level metric, which also gives us a start and end time
    metric = NewrelicAppMetric.first

    times = metric.generate_sample

    puts "returned #{times}"
    start = times[0].iso8601(0)
    finish = times[1].iso8601(0)

    count = 0

    fields = NewrelicMetric.uniq.pluck(:field)
    fields.each do |field|
      metrics = Metric.uniq.where(["field = ?", field]).pluck(:name)
      agent_ids = Metric.uniq.joins("LEFT OUTER JOIN agents ON agents.id = metrics.agent_id").where(["field = ?", field]).pluck("agents.agent_id").map { |r| r.to_s }

      agents = Agent.where(:agent_id => agent_ids)

      result = []
      metrics.each_slice(10) do |slice|
        tmp = Newrelic.get_value(agent_ids, slice, field, start, finish) || []
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

      puts "agents.count #{agents.count}"
      agents.each do |agent|
        if results_by_agent[agent.agent_id.to_i]
          agent.metrics.each do |metric|
            sample = results_by_agent[agent.agent_id.to_i].detect { |res| res["name"] == metric.name }
            if sample
              metric.populate(sample, start)
              count +=1
            end
          end
        end
      end
    end

    $stdout.puts "Generated #{count} samples from newrelic"
  end
end
