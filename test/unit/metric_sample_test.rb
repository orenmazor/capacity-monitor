require 'test_helper'

class MetricSampleTest < ActiveSupport::TestCase

  test "can be created" do
    sample = MetricSample.new
    sample.value = 1000
    sample.fetched_at = Time.now.utc
    sample.metric = Metric.first
    assert_difference "MetricSample.count", +1 do
      assert sample.save
    end
  end
end
