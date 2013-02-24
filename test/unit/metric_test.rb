require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  test "Metrics createable" do
    metric = Metric.new
    metric.name = "Disk IO"
    metric.host = "App1"
    metric.source = "NewRelic"
    metric.reference = "http://asdf.com"
    metric.maximum = 100
    assert metric.save
  end
end
