require 'test_helper'

class SampleTest < ActiveSupport::TestCase

  setup do
    @agent = Agent.first
  end

  test "Samples can do a thruzero prediction" do
    sample = samples(:slowcpu)
    sample.calculate_thruzero

    assert_equal 100000, sample.thruzero
  end

  test "samples for a grouped metric update the group sample" do
    first = Metric.new
    first.name ="CPU / IO Wait"
    first.group_name = "CPU"
    first.agent = @agent
    first.maximum = 100
    first.save!

    second = Metric.new
    second.name ="CPU / System"
    second.group_name = "CPU"
    second.agent = @agent
    second.maximum = 100
    second.save!

    assert_equal 1, @agent.metrics.where(:name => "CPU").count

    one = MetricSample.new
    one.run_id = 2000
    one.metric = first
    one.value = 10
    one.save!

    two = MetricSample.new
    two.run_id = 2000
    two.metric = second
    two.value = 20
    two.save!

    group_metric = @agent.metrics.where(:name => "CPU").first
    assert_equal 1, group_metric.samples.count
    assert_equal 30, group_metric.samples.first.value.to_i
  end
end
