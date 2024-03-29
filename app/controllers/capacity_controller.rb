class CapacityController < ApplicationController

  respond_to :html, :json

  def index
    @data = render_data
  end

  def data
    respond_with render_data
  end

  def render_data

    # Summaries look like { date =>, summary => [ {role => "app server", metric => "cpu", prediction => "10"},..]
    # and we want ["app server", "cpu"] => [[date, val],[date,val]]}

    sums = Summary.order('date DESC').limit(20)

    data = {}

    sums.each do |s|
      summary = JSON.parse(s.summary)
      summary.each do |pred|
        metric = pred["metric"].split(/\//)[1]
        metric = pred["metric"] if metric.nil?

        key = [pred["role"], metric]

        data[key] ||= []
        data[key] << [s.date, pred["prediction"]]
      end
    end

    data.map { |k,v| {"metric"=>k, "points"=>v} }
  end

  def summary
    respond_with JSON.parse(Summary.last.summary)
  end

end

