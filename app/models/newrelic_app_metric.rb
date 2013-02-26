class NewrelicAppMetric < Metric
  def fetch_value(*params)
    Newrelic.get_threshold_values(Newrelic.application.id).detect { |v| v["name"] == name }
  end

  def generate_sample
    sample = Sample.new
    sample.metric = self
    sample.value = fetch_value[field]
    sample.fetched_at = fetch_value["begin_time"]
    sample.save
    [fetch_value["begin_time"], fetch_value["end_time"]]
  end

end
