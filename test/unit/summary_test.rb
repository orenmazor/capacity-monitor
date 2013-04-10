require 'test_helper'

class SummaryTest < ActiveSupport::TestCase

  test "summaries can be created" do
    s = Summary.new
    s.date = Date.today()
    s.summary = "Summary"
    assert s.save
  end

end

