class CapacityController < ApplicationController

  respond_to :html, :json

  def index
  end

  def data
    start = Time.parse(params[:start]) if params.has_key?(:start)
    finish = Time.parse(params[:end]) if params.has_key?(:end)

    count = -1
    @metrics = predict(start, finish).map do |m|
      count += 1
      {
        :name => m.name,
        :host => m.agent.hostname,
        :prediction => m.prediction.to_i,
        :points => JSON.parse(m.points),
        :best_fit => JSON.parse(m.best_fit),
        :agent_id => m.agent.newrelic_id,
        :index => count
      }
    end

    respond_with @metrics
  end

  protected

  def predict(start, finish)
    metrics = []
    end_run = Run.order("id DESC").first.try(:id)
    start_run = Run.order("id DESC")[20].try(:id) || Run.order("id DESC").last.try(:id)

    unless start.nil?
      start_run = Run.where(["begin >= DATE(?)", start]).order("id ASC").first.try(:id)
    end

    unless finish.nil?
      end_run = Run.where(["begin <= DATE(?)", finish]).order("id ASC").last.try(:id)
    end

    return [] if start_run.nil? || end_run.nil? || start_run == end_run

    values_and_run_ids = FactSample.where(["run_id >= ? AND run_id <= ?", start_run, end_run])

    Metric.where(:relevant => true).includes(:metric_samples).includes(:agent).find_each do |metric|
      metric.curve_fit(values_and_run_ids)
      if metric.predict
        metrics << metric
      end
    end

    metrics.sort_by { |v| v.prediction }
  end
end

