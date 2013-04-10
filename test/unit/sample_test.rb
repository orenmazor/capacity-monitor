require 'test_helper'

class SampleTest < ActiveSupport::TestCase
  test "Samples can do a thruzero prediction" do
    sample = samples(:slowcpu)
    sample.calculate_thruzero

    assert_equal 100000, sample.thruzero
  end
end
