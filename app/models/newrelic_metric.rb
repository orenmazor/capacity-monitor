class NewrelicMetric < Metric
  def fetch_value(start=Time.now.utc-20.minutes, finish=Time.now.utc-10.minutes)
    Newrelic.get_json("https://api.newrelic.com/api/v1/agents/#{host.id}/data.json?metrics[]=#{name}&field=#{field}&summary=1&begin=2013-02-15T00:00:00Z&end=2013-02-16T00:00:00Z")
  end
end
