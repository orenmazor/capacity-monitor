require 'test_helper'

class OracleTest < ActiveSupport::TestCase
  setup do
  end

  test "predict returns results" do
    day = Run.last.begin.to_date
    assert_equal [35128, 44444, 60763, 98484], Oracle.predict(day).map { |i| i.prediction.to_i }
  end

  test "summary returns results" do
    day = Run.last.begin.to_date
    assert_equal [{:role=>"Application Server", :metric=>"System/Network/eth0/All/bytes/sec", :prediction=>39786},
                  {:role=>"Application Server", :metric=>"System/CPU/IO Wait/percent", :prediction=>79624}], Oracle.summary(day)
  end

  test "sample works" do
    start = Time.now
    finish = start - 20.minutes
    
    Newrelic.expects(:get_value).with(Newrelic.application.id, "HttpDispatcher", "requests_per_minute", start.iso8601(0), finish.iso8601(0)).once.returns([{"requests_per_minute" => 10000}])
    Newrelic.expects(:get_value).with([100, 102], ['System/Disk/dev^sd0/Reads/Utilization/percent', 'System/CPU/IO Wait/percent'], 'average_value', start.iso8601(0), finish.iso8601(0)).once.returns(
     [{"agent_id" => 100, "name" => "System/Disk/dev^sd0/Reads/Utilization/percent", "value" => 10},
      {"agent_id" => 100, "name" => "System/CPU/IO Wait/percent", "value" => 10},
      {"agent_id" => 102, "name" => "System/CPU/IO Wait/percent", "value" => 20}]
      )
    Newrelic.expects(:get_value).with([100, 102, 101], ['System/Network/eth0/All/bytes/sec'], 'max_per_second', start.iso8601(0), finish.iso8601(0)).once.returns(
     [{"agent_id" => 100, "name" => "System/Network/eth0/All/bytes/sec", "value" => 15},
      {"agent_id" => 102, "name" => "System/Network/eth0/All/bytes/sec", "value" => 16},
      {"agent_id" => 101, "name" => "System/Network/eth0/All/bytes/sec", "value" => 17}])

    assert_difference "MetricSample.count", +6 do
      Oracle.sample(start, finish)
    end
  end
end
