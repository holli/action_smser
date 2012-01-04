require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "basic gateway_commit delivery_report" do
    get 'action_smser/delivery_reports/gateway_commit/example_gateway'
    assert_response :success
  end
end

