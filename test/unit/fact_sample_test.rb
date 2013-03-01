require 'test_helper'

class FactSampleTest < ActiveSupport::TestCase

  test "can be created" do
    sample = nil
    assert_difference "FactSample.count", +1 do
      sample = FactSample.create(:run => Run.create, :value => 5001)
    end

    assert_equal 1, sample.bucket_number
  end

  test "fixtures loaded" do
    assert_equal 2, FactSample.count
  end

end
