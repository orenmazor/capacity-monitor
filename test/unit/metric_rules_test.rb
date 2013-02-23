require 'test_helper'

class MetricRulesTest < ActiveSupport::TestCase
  test "rules get loaded" do
    assert_equal 7, MetricRules.rules.count
  end

  test "rules match metrics" do
    assert MetricRules.match?("app1", "System/Disk/^dev^xvda1/Reads/Utilization/percent")
  end

  test "rules don't match metrics to drop" do
    assert !MetricRules.match?("app1", "System/Disk/^dev^sdf/Writes/bytes/sec")
  end
end
