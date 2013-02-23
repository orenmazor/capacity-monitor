require 'test_helper'

class MetricRulesTest < ActiveSupport::TestCase
  test "rules get loaded" do
    assert_equal 7, MetricRules.rules.count
  end
end
