require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  test "Metrics createable" do
    host = Host.new

    metric = Metric.new
    metric.name = "Disk IO"
    metric.host = host
    metric.source = "NewRelic"
    metric.reference = "http://asdf.com"
    metric.maximum = 100
    assert metric.save
  end
end
