require 'matrix'

class Metric < ActiveRecord::Base
  belongs_to :agent

  has_many :samples

  attr_accessor :points, :prediction, :best_fit

  def generate_points(fact_samples)
    run_ids = fact_samples.map(&:run_id)

    smpls = samples.where(["run_id in (?)", run_ids]).order("id ASC")
    points = []

    smpls.each do |sample|
      points << [fact_samples_by_run_id[sample.run_id].value, sample.value]
    end
  end

  def reverse(points)
    points.map { |point| point.reverse }
  end

  def curve_fit(fact_samples)
    y = fact_samples.map { |v| v.value.to_f }
    run_ids = fact_samples.map(&:run_id)
    x = []

    run_ids.each_with_index do |run, i|
      val = samples.detect { |s| s.run_id == run }.value
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

