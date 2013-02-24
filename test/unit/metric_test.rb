require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  test "Metrics createable" do
    host = Host.new( :fetched_at => Time.now)
    host.id = 100
    host.save

    metric = Metric.new
    metric.name = "Disk IO"
    metric.host = host
    metric.source = "NewRelic"
    metric.reference = "http://asdf.com"
    metric.maximum = 100
    assert metric.save
  end
end
