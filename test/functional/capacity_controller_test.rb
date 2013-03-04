require 'test_helper'

class CapacityControllerTest < ActionController::TestCase
  test "data returns relevant predictions" do
    get :data, :format => :json
    assert_response :ok

    data = JSON.parse(@response.body)
    assert_equal 1, data.count
    assert_equal 53846, data.first["prediction"]
  end

  test "data accepts start and end time paramters" do
    get :data, :format => :json, :start => "2013-02-27 21:30:00 -0000", :end => "2013-03-01 04:40:28 -0000"
    assert_response :ok

    data = JSON.parse(@response.body)
    assert_equal 1, data.count
    assert_equal 100000, data.first["prediction"]
  end

end
