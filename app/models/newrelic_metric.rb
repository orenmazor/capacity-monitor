class NewrelicMetric < Metric
  def fetch_value(start, finish)
    name = URI.encode(self.name)
    url = "https://api.newrelic.com/api/v1/agents/#{agent.agent_id}/data.json?metrics[]=#{name}&field=#{field}&summary=1&begin=#{start.iso8601(0)}&end=#{finish.iso8601(0)}"
    Newrelic.get_json(url)
  end

  def generate_sample(start=Time.now.utc-20.minutes, finish=Time.now.utc-10.minutes)
    raw = fetch_value(start, finish)
    if raw.nil? || raw[0].empty?
      puts "Error generating sample for #{agent}:#{name}"
      return
    end
    value = raw[0][field]
    if maximum
      value /= maximum
    end


    self.samples.create(:value => value, :fetched_at => start)
  end
end
