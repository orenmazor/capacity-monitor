class CapacityController < ApplicationController
  attr_accessor :metrics

  def index
    @metrics = Metric.where("prediction > 0 AND slope > 0").order("prediction ASC").limit(20)
  end

  protected

  def build_samples
    @metrics = []
  end
end

