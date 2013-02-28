require 'test_helper'

class MetricRulesTest < ActiveSupport::TestCase
  test "rules match metrics" do
    assert MetricRules.match?({"name" => "System/Disk/^dev^xvda1/Reads/Utilization/percent"})
  end

  test "rules don't match metrics to drop" do
    assert !MetricRules.match?({"name" => "System/Disk/^dev^sdf/Writes/bytes/sec"})
  end
end
