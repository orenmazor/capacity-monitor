class CapacityController < ApplicationController
  attr_accessor :metrics

  def index
    build_samples

    @metrics = @metrics[0..10]
  end

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
        metric.points.sort_by! { |p| p[1] }
        @metrics << metric
      end
    end
  end
end
