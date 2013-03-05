require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.new
    @agent.id = 100
    @agent.save

    @metric = Metric.new
    @metric.name = "Disk IO"
    @metric.agent = @agent
    @metric.maximum = 100
  end

  test "Metrics createable" do
    assert @metric.save
  end

  test "Metric can create samples" do
    @metric.save
    assert_difference "Sample.count", +1 do
      @metric.samples.create(:value => 100, :run => Run.create)
    end
  end

  test "Metric can curve fit" do
    metric = metrics(:app_cpu)
    fact_samples = FactSample.order("id ASC")
    metric.curve_fit(fact_samples)
    assert metric.slope > 943 && metric.slope < 944
    assert metric.offset > 645 && metric.offset < 646
  end

  test "Metric knows when it's irrelevant" do
    metric = metrics(:disk)
    metric.update_relevance
    assert !metric.relevant

    metric = metrics(:app_cpu)
    metric.update_relevance
    assert metric.relevant
  end
end
