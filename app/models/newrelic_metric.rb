class NewrelicMetric < Metric
  def fetch_value(start=Time.now.utc-20.minutes, finish=Time.now.utc-10.minutes)
    Newrelic.get_json("https://api.newrelic.com/api/v1/agents/#{agent.id}/data.json?metrics[]=#{name}&field=#{field}&summary=1&begin=2013-02-20T00:00:00Z&end=2013-02-21T00:00:00Z")
  end

  def generate_sample
    
  end
end
