
class Oracle

  def self.summary(day)
    @metrics = predict(day)
    @summary = @metrics.group_by { |m| [m.agent.role, m.name] }
    @summary = @summary.map do |k, v|
    {
      :role => k[0],
      :metric => k[1],
      :prediction => (v.inject(0) { |sum, metric| sum + metric.prediction } / v.count).to_i
    }
    end.sort_by { |result| result[:prediction]}
  end

  def self.predict(day = Date.yesterday)

    metrics = []
    start_run = Run.where(["begin >= DATE(?)", day]).order("id ASC").first.try(:id)
    end_run = Run.where(["begin <= DATE(?)", day]).order("id ASC").last.try(:id)

    return [] if start_run.nil? || end_run.nil? || start_run == end_run

    values_and_run_ids = FactSample.where(["run_id >= ? AND run_id <= ?", start_run, end_run])

    Metric.where(:relevant => true, :group_metric_id => nil).includes(:metric_samples).includes(:agent).find_each do |metric|
      metric.curve_fit(values_and_run_ids)
      if metric.prediction != 0
        metrics << metric
      end
    end

    metrics.sort_by { |v| v.prediction }
  end
end
