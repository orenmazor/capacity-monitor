class CapacityController < ApplicationController
  def index
    @metrics = Metric.all
  end
end
