require 'test_helper'

class AgentTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.new
    @agent.newrelic_id = 100
  end

  test "basic matching" do
    assert Agent.match?("app1.server.com")
    assert Agent.match?("db1.server.com")
    assert Agent.match?("memcache1.server.com")
    assert Agent.match?("redis1.server.com")
  end

  test "blacklisting" do
    assert !Agent.match?("app1-stats.server.com")
    assert !Agent.match?("app1.staging.server.com")
  end

  test "fetching metrics from Newrelic" do
    mock_newrelic_metrics
    assert_equal 1, @agent.fetch_metrics.count
  end

  test "syncing metrics from Newrelic" do
    mock_newrelic_metrics
    @agent.save!
    assert_difference "NewrelicMetric.count", +1 do
      @agent.sync_metrics
    end
    assert_equal 1, @agent.metrics.count
    metric = @agent.metrics.first
    assert_equal "System/Disk/^dev^sd0/Writes/Utilization/percent", metric.name
    assert_equal "average_value", metric.field
    assert_equal nil, metric.maximum
  end

  test "metrics know their group" do
    Newrelic.expects(:get_metrics).once.returns([{"name" => "System/CPU/User/percent", "fields" => "average_value"}, {"name" => "System/CPU/System/percent", "field" => "average_value"}])
    @agent.save!
    @agent.sync_metrics
    assert_equal 2, @agent.metrics.count
    assert_equal "CPU", @agent.metrics[0].group
    assert_equal "CPU", @agent.metrics[1].group
  end

  def mock_newrelic_metrics
    Newrelic.expects(:get_metrics).once.returns([{"name" => "System/Disk/^dev^sd0/Writes/Utilization/percent", "fields" => "average_value"}, {"name" => "unmatching metric", "field" => "dont care"}])
  end
end

