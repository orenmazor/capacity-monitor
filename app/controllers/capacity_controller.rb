class CapacityController < ApplicationController

  respond_to :html, :json

  def index
  end

  def data
    @metrics = Metric.where("prediction > 0 AND slope > 0").order("prediction ASC")
    @metrics.reject! { |m| !m.relevant? }

    count = -1
    @metrics = @metrics.map do |m|
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
    respond_with [{}] + @metrics
  end

  protected

  def build_samples
    @metrics = []
  end
end

