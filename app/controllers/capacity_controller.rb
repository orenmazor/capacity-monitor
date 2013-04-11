class CapacityController < ApplicationController

  respond_to :html, :json

  def index
  end

  def data

    # Summaries look like { date =>, summary => [ {role => "app server", metric => "cpu", prediction => "10"},..]
    # and we want ["app server", "cpu"] => [[date, val],[date,val]]}
    
    sums = Summary.order('date DESC').limit(20)

    data = {}
   
    sums.each do |s|
      summary = JSON.parse(s.summary)
      summary.each do |pred|
        key = [pred["role"], pred["metric"]]

        data[key] ||= []
        data[key] << [s.date, pred["prediction"]]
      end
    end

    
    respond_with data.map { |k,v| {"metric"=>k, "points"=>v} }
  end

  def summary
    respond_with {JSON.parse(Summary.last.summary)}
  end

end

