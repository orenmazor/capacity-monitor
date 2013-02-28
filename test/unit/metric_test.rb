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
end
