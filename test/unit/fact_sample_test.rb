require 'test_helper'

class FactSampleTest < ActiveSupport::TestCase

  test "can be created" do
    sample = FactSample.new
    sample.value = 1000
    sample.fetched_at = Time.now.utc
    assert_difference "FactSample.count", +1 do
      assert sample.save
    end
  end
end
