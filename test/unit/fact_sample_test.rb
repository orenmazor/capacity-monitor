require 'test_helper'

class FactSampleTest < ActiveSupport::TestCase

  test "can be created" do
    sample = FactSample.new
    sample.value = 5001
    sample.run = Run.create

    assert_difference "FactSample.count", +1 do
      assert sample.save
    end

    sample.reload

    assert_equal 1, sample.bucket_number
  end

  test "fixtures loaded" do
    assert_equal 2, FactSample.count
  end

end
