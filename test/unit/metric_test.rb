require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  test "Metrics createable" do
    agent = Agent.new( :fetched_at => Time.now)
    agent.id = 100
    agent.save

    metric = Metric.new
    metric.name = "Disk IO"
    metric.agent = agent
    metric.source = "NewRelic"
    metric.reference = "http://asdf.com"
    metric.maximum = 100
    assert metric.save
  end
end
