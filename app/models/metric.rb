class Metric < ActiveRecord::Base
  belongs_to :agent

  has_many :samples

  attr_accessor :points, :prediction, :best_fit

  def generate_points(facts)
    run_ids = facts.map(&:run_id)
    facts_by_run_id = {}
    facts.each do |fact|
      facts_by_run_id[fact.run_id] = fact
    end

    metrics = Metric.find(run_ids)
    points = []
    metrics.each do |metric|
      points << [facts_by_run_id[metric.run_id].value, metric.value]
    end
  end

  def reverse(points)
    points.map { |point| point.reverse }
  end

  def calculate_graph(facts)
    points = generate_points(facts)
    results = CurveFit.new.fit(points, 100)

    # serialize and save
    points_cache = reverse(points)
    
  end
end

