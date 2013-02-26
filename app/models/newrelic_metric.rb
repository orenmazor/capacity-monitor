class NewrelicMetric < Metric

  def generate_sample(start=Time.now.utc-20.minutes, finish=Time.now.utc-10.minutes)
    raw = Newrelic.get_value(agent.agent_id, name, start, finish)
    if raw.nil? || raw[0].empty?
      puts "Error generating sample for #{agent.agent_id}:#{name}"
      return
    end
    value = raw[0][field]
    if maximum
      value /= maximum
    end

    self.samples.create(:value => value, :fetched_at => start)
  end
end
