require 'matrix'

class Metric < ActiveRecord::Base
  RELEVANCE_PCT_THRESHOLD = 4
  IRRELEVANT = 6

  belongs_to :agent
  attr_accessor :confidence, :points, :prediction, :best_fit

  has_many :metric_samples, :dependent => :destroy
  alias :samples :metric_samples

  def reverse(points)
    points.map { |point| point.reverse }
  end

  def filter_samples(x, y, &block)
    index = x.length-1
    x.reverse_each do |v|
      if yield(v, y[index])
        x.delete_at(index)
        y.delete_at(index)
      end
      index -= 1
    end
    [x, y]
  end

  def curve_fit(fact_samples)
    run_ids = fact_samples.map(&:run_id)

    metrics_unordered = metric_samples.where(:run_id => run_ids)

    thruzero = []
    x = []

    y = fact_samples.map(&:value)

    run_ids.each_with_index do |run, i|
      sample = metrics_unordered.detect { |s| s.run_id == run }
      if sample.nil? || sample.value < IRRELEVANT
        x << nil
      else
        if sample.thruzero.nil?
          sample.calculate_thruzero
          sample.save!
        end
        thruzero << sample.thruzero
        x << sample.value
      end
    end

    x, y = filter_samples(x, y) { |v, w| v.nil? || w.nil? || v < IRRELEVANT }

    if x.count != y.count || x.uniq.count < 2
      self.prediction = 0
      self.confidence = 0
      return
    end

    predict(thruzero)
    points = []
    x.each_with_index { |v, i| points << [v, y[i]] }
    self.points = points.to_json
  end

  def predict(thruzero)
    # these are a bunch of values for RPM at 100% utilization
    # predicted by each sample
    average = thruzero.mean
    stddev = thruzero.standard_deviation

    thruzero.reject! { |v| v < average - (2*stddev) || v > average + (2*stddev) }
    self.confidence = thruzero.standard_deviation
    self.prediction = thruzero.mean
    self.best_fit = [[0,0],[100,self.prediction]].to_json
  end

  def update_relevance
    if samples.where(["value > ?", IRRELEVANT]).count < 2
      self.relevant = false
    else
      sql = "SELECT MAX(value), MIN(value) FROM samples WHERE metric_id = #{id} AND value > #{IRRELEVANT}"
      max, min = ActiveRecord::Base.connection.select_rows(sql).first
      self.relevant = (max.to_f-min.to_f > RELEVANCE_PCT_THRESHOLD)
    end
  end

private

end

