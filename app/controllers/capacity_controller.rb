class CapacityController < ApplicationController
  attr_accessor :metrics

  def index
    @metrics = Metric.where("prediction > 0 AND slope > 0").order("prediction ASC")
    @metrics.reject! { |m| !m.relevant? }
  end

  protected

  def build_samples
    @metrics = []
  end
end

