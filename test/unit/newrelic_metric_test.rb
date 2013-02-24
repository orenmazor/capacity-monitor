require 'test_helper'

class NewrelicMetricTest < ActiveSupport::TestCase
  test "fetch value sets fetched_at on success" do
    agent = Agent.new
    agent.hostname = 'omgponies.com'
    agent.id = 100
    agent.fetched_at = Time.now.utc - 2.hours
    agent.save

    metric = NewrelicMetric.new
    metric.agent = agent
    metric.name = 'ALL the things'
    metric.field = 'thing'
    metric.save


    start_time = Time.now.utc - 10.minutes
    finish_time = start_time + 1.hour

    Newrelic.expects(:get_json).returns([{'thing' => '5.0'}])

    metric.generate_sample(start_time,  finish_time)

    metric.samples.each{ |s| assert s.fetched_at }
  end
end
