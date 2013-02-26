class NewrelicAppMetric < Metric
  def fetch_value(*params)
    Newrelic.get_threshold_values(Newrelic.application.id).detect { |v| v["name"] == name }
  end

  def generate_sample(start, finish)
    v = fetch_value[field]
    sample = Sample.new
    sample.metric = self
    sample.value = calculate_value(v)
    sample.fetched_at = start
    sample.save
  end


  private

  def calculate_value(raw_value)
    if name =~ /Network/
      (raw_value.to_f / maximum.to_f) * 100
    else
      raw_value
    end
  end
end
