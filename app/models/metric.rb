require 'matrix'

class Metric < ActiveRecord::Base
  RELEVANCE_PCT_THRESHOLD = 4
  OUTLIER_STD = 2
  IRRELEVANT = 6

  belongs_to :agent
  attr_accessor :slope, :offset, :points, :best_fit, :prediction

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

  def generate_points(fact_samples)
    y = fact_samples.map { |v| v.value.to_f }
    run_ids = fact_samples.map(&:run_id)
    x = []

    run_ids.each_with_index do |run, i|
      x << metric_samples.detect { |s| s.run_id == run }.try(:value)
    end

    x,y = filter_samples(x, y) { |v, w| v.nil? }

    stddev = x.standard_deviation
    mean = x.mean
    min = mean - (stddev*OUTLIER_STD)
    max = mean + (stddev*OUTLIER_STD)

    x,y = filter_samples(x, y) { |v, w| v < min || v > max || v < IRRELEVANT }

    x.map! { |v| v.to_f }
    [x, y]
  end

  def curve_fit(fact_samples)
    x, y = generate_points(fact_samples)

    if x.count != y.count || x.uniq.count < 2
      self.slope = self.offset = 0
      return
    end
    self.slope, self.offset = regression(x, y, 1)
    predict
    points = []
    x.each_with_index { |v, i| points << [v, y[i]] }
    self.points = points.to_json
  end

  def predict
    self.prediction = ((self.slope * 100.0) + self.offset)
    self.best_fit = [[0, self.offset], [100, self.prediction]].to_json
    self.slope > 0 && self.prediction > 0
  end

  def update_relevance
    if samples.count < 2
      self.relevant = false
    else
      sql = "SELECT MAX(value), MIN(value) FROM samples WHERE metric_id = #{id}"
      max, min = ActiveRecord::Base.connection.select_rows(sql).first
      self.relevant = (max.to_f-min.to_f > RELEVANCE_PCT_THRESHOLD)
    end
  end

private

  def regression(x, y, degree)
    x_data = x.map {|xi| (0..degree).map{|pow| (xi**pow) }}

    mx = Matrix[*x_data]
    my = Matrix.column_vector(y)

    ((mx.t * mx).inv * mx.t * my).transpose.to_a[0].reverse
  end
end

