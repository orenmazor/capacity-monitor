require 'test_helper'

class CapacityControllerTest < ActionController::TestCase
  test "data returns relevant predictions" do
    get :data, :format => :json
    assert_response :ok

    data = JSON.parse(@response.body)
    assert_equal 1, data.count
    assert_equal 100000, data.first["prediction"]
  end
end
