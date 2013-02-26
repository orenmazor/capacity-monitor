class CapacityController < ApplicationController
  attr_accessor :metrics

  def index
    build_samples
    predict

    @metrics = @metrics[0..10]
  end

  protected

  def build_samples
    @metrics = []

    @app_metric = NewrelicAppMetric.first
    app_samples = @app_metric.samples
    app_samples_by_fetched = {}
    app_samples.each { |a| app_samples_by_fetched[a.fetched_at] = a }

    NewrelicMetric.find_each do |metric|
      metric.points = []
      samples = metric.samples.order("fetched_at DESC").limit(10)
      samples.each do |sample|
        metric.points << [sample.value.to_f, app_samples_by_fetched[sample.fetched_at].value.to_f]
      end
      if metric.points.count > 1
        metric.points.sort_by! { |p| p[0] }
        @metrics << metric
      end
    end
  end

  def predict
    @metrics.each do |metric|
      first = metric.points.first
      last = metric.points.last
      # rise / run
      m = (last[1] - first[1]) / (last[0] - first[0])

      # y = mx + b
      b = first[1] - (m*first[0])
      metric.prediction = ((m * 100.0) + b)
      Rails.logger.info "m #{m}, b #{b}, prediction is #{metric.prediction}"
    end
    @metrics.reject! { |m| m.prediction < 0 || m.prediction.nan? }.sort_by! { |m| m.prediction }
  end
end
