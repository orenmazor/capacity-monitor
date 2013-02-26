class NewrelicMetric < Metric

  def populate(raw)
    value = raw[0][field]
    value = maximum ? ((value.to_f / maximum.to_f) * 100) : value

    self.samples.create(:value => value, :fetched_at => start)
  end

  def generate_sample(start=Time.now.utc-20.minutes, finish=Time.now.utc-10.minutes)
    raw = Newrelic.get_value(agent.agent_id, name, start, finish)
    if raw.nil? || raw[0].empty?
      puts "Error generating sample for #{agent.agent_id}:#{name} - raw #{raw}"
      return
    end
    populate(raw)
  end
end
