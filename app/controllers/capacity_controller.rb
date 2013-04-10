class CapacityController < ApplicationController

  respond_to :html, :json

  def index
  end

  def data
    @sums = Summary.order('date DESC').limit(20).map do |s|
      { "date" => s.date, "summary" => JSON.parse(s.summary)}
    end

    respond_with @sums
  end

  def summary
    respond_with JSON.parse(Summary.last.summary)
  end

end

