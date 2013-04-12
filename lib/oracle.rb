
class Oracle

  def self.summary(day)
    @metrics = predict(day)
    @summary = @metrics.group_by { |m| [m.agent.role, m.name] }
    @summary = @summary.map do |k, v|
    {
      :role => k[0],
      :metric => k[1],
      :prediction => (v.inject(0) { |sum, metric| sum + metric.prediction } / v.count).to_i
    }
    end.sort_by { |result| result[:prediction]}
  end

  def self.predict(day = Date.yesterday)
    metrics = []
    runs_for_day = Run.where(["DATE(begin) = DATE(?)", day]).order("id ASC")
    start_run = runs_for_day.first.try(:id)
    end_run = runs_for_day.last.try(:id)

    return [] if start_run.nil? || end_run.nil? || start_run == end_run

    values_and_run_ids = FactSample.where(["run_id >= ? AND run_id <= ?", start_run, end_run])

    Metric.where(:relevant => true, :group_metric_id => nil).includes(:metric_samples).includes(:agent).find_each do |metric|
      metric.curve_fit(values_and_run_ids)
      if metric.prediction != 0
        metrics << metric
      end
    end

    metrics.sort_by { |v| v.prediction }
  end

  def self.sample(start, finish)
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
      count += Oracle.process_results(run, field, agents, result)
    end
    $stdout.puts "Generated #{count} samples from newrelic"
  end
  
  def self.process_results(run, field, agents, result)
    count = 0
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
            m.save!
            count +=1
          end
        end
      else
        puts "No results for agent #{agent.hostname}"
      end
    end
    count
  end

  def self.update_relevance
    Metric.find_each do |metric|
      metric.update_relevance
      metric.save
    end
  end
end
