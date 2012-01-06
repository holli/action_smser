require 'test_helper'

class ActionSmser::DeliveryReportsControllerTest < ActionController::TestCase

  class SmsTestSetup
    def self.admin_access(controller)
      if controller.session[:admin_logged].blank?
        return controller.session[:admin_logged]
      else
        return true
      end
    end

    def self.process_delivery_report(params)
      if params["DeliveryReport"] && params["DeliveryReport"]["message"]
        info = params["DeliveryReport"]["message"]
        return info["id"], info["status"]
      else
        return nil, nil
      end
    end
  end

  test "gateway_commit with existing dr" do
    @msg_id = "102010314204056202"
    @dr = ActionSmser::DeliveryReport.create(:msg_id => @msg_id, :status => 'ORIGINAL_STATUS')

    ActionSmser.delivery_options[:gateway_commit] = {'test_gateway' => SmsTestSetup}

    get 'gateway_commit', :use_route => :action_smser, :gateway => 'test_gateway',
        "DeliveryReport"=>{"message"=>{"id"=>@msg_id, "donedate"=>"2012/01/03 14:20:45", "sentdate"=>"2012/01/03 14:20:40", "status"=>"DELIVERED"}}


    assert_response :success
    assert @response.body.include?("Update"), "should have responed about saving"
    @dr.reload
    assert_equal "DELIVERED", @dr.status

  end

  test "gateway_commit without dr" do
    ActionSmser.delivery_options[:gateway_commit] = {'test_gateway' => SmsTestSetup}

    get 'gateway_commit', :use_route => :action_smser, :gateway => 'test_gateway',
        "DeliveryReport"=>{"message"=>{"id"=>"wrongid", "donedate"=>"2012/01/03 14:20:45", "sentdate"=>"2012/01/03 14:20:40", "status"=>"DELIVERED"}}

    assert_response :success
    assert @response.body =~ /not/i, "should have responded not saved"
  end

  test "gateway_commit without any parser" do
    get 'gateway_commit', :use_route => :action_smser, :gateway => 'gateway_not_found',
        "DeliveryReport"=>{"message"=>{"id"=>"wrongid", "donedate"=>"2012/01/03 14:20:45", "sentdate"=>"2012/01/03 14:20:40", "status"=>"DELIVERED"}}

    assert_response :success
    assert @response.body =~ /not/i, "should have responded not saved"
  end


  test "admin_access_only" do
    get 'index', :use_route => :action_smser
    assert_response 403
    assert_template nil
  end

  test "index with always enabled admin" do
    2.times do
      ActionSmser::DeliveryReport.create(:msg_id => "idtest_#{rand(10)}")
    end
    ActionSmser::DeliveryReportsController.any_instance.stubs(:admin_access_only).returns(true)
    get 'index', :use_route => :action_smser
    assert_response :success
    assert_template :index
  end

  test "admin_access_only setup with class" do
    default = ActionSmser.delivery_options[:admin_access]
    ActionSmser.delivery_options[:admin_access] = SmsTestSetup
    2.times do
      ActionSmser::DeliveryReport.create(:msg_id => "idtest_#{rand(10)}")
    end
    session[:admin_logged] = true
    get 'index', :use_route => :action_smser

    assert_response :success
    assert_template :index

    ActionSmser.delivery_options[:admin_access] = default

  end

end
