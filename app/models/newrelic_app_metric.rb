class NewrelicAppMetric < Metric
  def fetch_value(*params)
    Newrelic.get_threshold_values(Newrelic.application.id).detect { |v| v["name"] == name }
  end

  def generate_sample
    sample = Sample.new
    sample.metric = self
    sample.value = fetch_value[field]

    begin_time = Time.parse(fetch_value["begin_time"])
    end_time = Time.parse(fetch_value["end_time"])

    begin_time, end_time = end_time, begin_time if end_time < begin_time

    sample.fetched_at = begin_time
    sample.save

    [begin_time, end_time]
  end

end
