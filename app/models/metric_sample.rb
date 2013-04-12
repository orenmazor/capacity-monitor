class MetricSample < Sample
  belongs_to :metric

  before_save :recreate_group_sample

  def value=(v)
    write_attribute(:value, metric.maximum ? ((v.to_f / metric.maximum.to_f) * 100) : v)
  end

  def recreate_group_sample
    return true unless metric.group_metric
    metric.group_metric.samples.where(:run_id => self.run_id).delete_all
    grouped = MetricSample.new
    grouped.metric = metric.group_metric

    metric_ids = Metric.where(:group_metric_id => metric.group_metric.id).map(&:id)
    samples = Sample.where(["run_id = ? AND metric_id in (?)", self.run_id, metric_ids])
    grouped.run_id = self.run_id
    grouped.value = samples.sum { |s| s.value }
    grouped.value += self.value if new_record?
    grouped.save!
    true
  end
end
