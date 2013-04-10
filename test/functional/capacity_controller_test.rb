require 'test_helper'

class CapacityControllerTest < ActionController::TestCase
  test "summary returns json when requested" do
    get :summary, :format => :json
    assert_response :ok

    data = JSON.parse(@response.body)

    assert data.is_a?(Array)
    assert !data.empty?
    assert_equal 2, data.count
    assert data.first.is_a?(Hash)

    assert_equal "Application Server", data.first['role']
    assert_equal "System/Network/eth0/All/bytes/sec", data.first['metric']
    assert_equal nil, data.first['host']
    assert_equal nil, data.first['hostname']
  end

  test "summary also returns html" do
    get :summary
    assert_response :ok
  end

end
