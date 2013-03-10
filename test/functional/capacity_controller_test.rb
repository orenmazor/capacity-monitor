require 'test_helper'

class CapacityControllerTest < ActionController::TestCase
  test "data returns relevant predictions" do
    get :data, :format => :json
    assert_response :ok

    data = JSON.parse(@response.body)
    assert_equal 1, data.count
    assert_equal 3, data.first["points"].count
    assert_equal 94999, data.first["prediction"]
  end

  test "data accepts start and end time paramters" do
    get :data, :format => :json, :start => "2013-02-27 21:30:00 -0000", :end => "2013-03-01 04:40:28 -0000"
    assert_response :ok

    data = JSON.parse(@response.body)
    assert_equal 1, data.count
    assert_equal 2, data.first["points"].count
    assert_equal 100000, data.first["prediction"]
  end

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
    assert data.first['prediction'] > 142822 && data.first['prediction'] < 142823
  end

  test "summary also returns html" do
    get :summary
    assert_response :ok
  end

end
