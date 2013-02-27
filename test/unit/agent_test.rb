require 'test_helper'

class AgentTest < ActiveSupport::TestCase
  test "basic matching" do
    assert Agent.match?("app1.server.com")
    assert Agent.match?("db1.server.com")
    assert Agent.match?("memcache1.server.com")
    assert Agent.match?("redis1.server.com")
  end

  test "blacklisting" do
    assert !Agent.match?("app1-stats.server.com")
    assert !Agent.match?("app1.staging.server.com")
  end
end
