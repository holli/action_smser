require File.dirname(__FILE__) + '/../../test_helper'

class ActionSmser::DeliveryReportsControllerTest < ActionController::TestCase

  test "gateway_commit with existing dr" do
    @msg_id = "102010314204056202"
    @dr = ActionSmser::DeliveryReport.create(:msg_id => @msg_id, :status => 'ORIGINAL_STATUS')
    get 'gateway_commit', :use_route => :action_smser, :gateway => 'test_gateway',
        "DeliveryReport"=>{"message"=>{"id"=>@msg_id, "donedate"=>"2012/01/03 14:20:45", "sentdate"=>"2012/01/03 14:20:40", "status"=>"DELIVERED"}}


    assert_response :success
    assert @response.body.include?("Update"), "should have responed about saving"
    @dr.reload
    assert_equal "DELIVERED", @dr.status

  end

  test "gateway_commit without dr" do
    get 'gateway_commit', :use_route => :action_smser, :gateway => 'test_gateway',
        "DeliveryReport"=>{"message"=>{"id"=>"wrongid", "donedate"=>"2012/01/03 14:20:45", "sentdate"=>"2012/01/03 14:20:40", "status"=>"DELIVERED"}}

    assert_response :success
    assert @response.body =~ /not/i, "should have responded not saved"
  end


  test "admin_access_only" do
    get 'index', :use_route => :action_smser
    assert_response 403
  end
end
