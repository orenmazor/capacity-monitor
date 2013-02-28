require 'test_helper'

class FactTest < ActiveSupport::TestCase

  def setup
    @fact = Fact.new
    @fact.resource = "resource-uri"
    @fact.save
  end

  test "Fact can create samples" do
    assert_difference "Sample.count", +1 do
      @fact.samples.create(:value => 100, :fetched_at => Time.now.utc)
    end
  end

end
