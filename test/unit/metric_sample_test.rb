require 'test_helper'

class MetricSampleTest < ActiveSupport::TestCase

  test "can be created" do
    sample = MetricSample.new
    sample.value = 1000
    sample.run = Run.create
    sample.metric = Metric.first

    assert_difference "MetricSample.count", +1 do
      assert sample.save
    end

  end

  test "should normalize values with a maximum" do
    metric = Metric.first
    metric.maximum = 2000
    sample = MetricSample.new
    sample.value = 1000
    sample.run = Run.create
    sample.metric = metric

    assert_difference "MetricSample.count", +1 do
      assert sample.save
    end

    assert_equal 50.0, sample.value.to_f

  end
end
