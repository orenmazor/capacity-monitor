class MetricSample < Sample
  belongs_to :metric

  before_create :normalize_value
  def normalize_value
    self.value = metric.maximum ? ((value.to_f / metric.maximum.to_f) * 100) : value
  end
end
