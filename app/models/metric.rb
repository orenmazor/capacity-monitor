require 'matrix'

class Metric < ActiveRecord::Base
  belongs_to :agent

  has_many :metric_samples
  alias :samples :metric_samples

  attr_accessor :points

  def reverse(points)
    points.map { |point| point.reverse }
  end

  def curve_fit(fact_samples)
    y = fact_samples.map { |v| v.value.to_f }
    run_ids = fact_samples.map(&:run_id)
    x = []

    run_ids.each_with_index do |run, i|
      val = metric_samples.detect { |s| s.run_id == run }.try(:value)
      if val.nil? || x.detect { |v| v == val }
        y.delete_at(i)
      else
        x << val
      end
    end

    x.map! { |v| v.to_f }

    if x.uniq.count != y.uniq.count || x.uniq.count == 1
      self.slope = self.offset = 0
      return
    end

    self.slope, self.offset = regression(x, y, 1)
    predict
  end

  def predict
    self.prediction = ((self.slope * 100.0) + self.offset)
    self.best_fit = [[0, self.offset], [100, self.prediction]].to_json
  end

  def relevant?
    self.slope <= 0
  end

private

  def regression(x, y, degree)
    x_data = x.map {|xi| (0..degree).map{|pow| (xi**pow) }}

    mx = Matrix[*x_data]
    my = Matrix.column_vector(y)

    ((mx.t * mx).inv * mx.t * my).transpose.to_a[0].reverse
  end
end

