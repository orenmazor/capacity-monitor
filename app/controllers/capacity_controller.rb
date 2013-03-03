class CapacityController < ApplicationController

  respond_to :html, :json

  def index
  end

  def data
    count = -1
    @metrics = predict.map do |m|
      count += 1
      {
        :name => m.name,
        :host => m.agent.hostname,
        :prediction => m.prediction.to_i,
        :points => JSON.parse(m.points),
        :best_fit => JSON.parse(m.best_fit),
        :index => count
      }
    end

    respond_with [@metrics.first] + @metrics
  end

  protected

  def predict
    metrics = []
    values_and_run_ids = FactSample.find_latest_values_and_run_ids_per_bucket

    Metric.where(:relevant => true).find_each do |metric|
      metric.curve_fit(values_and_run_ids)
      if metric.predict
        metrics << metric
      end
    end

    metrics.sort_by { |v| v.prediction }
  end
end

