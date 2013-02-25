class NewrelicAppMetric < Metric
  def fetch_value(*params)
    Newrelic.get_threshold_values(Newrelic.application.id).detect { |v| v["name"] == name }
  end

  def generate_sample(start, finish)
    v = fetch_value[field]
    sample = Sample.new
    sample.metric_id = id
    sample.value = v
    sample.fetched_at = start
    sample.save
  end
end
