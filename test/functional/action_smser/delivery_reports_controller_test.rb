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
      processable_array = []
      if params["DeliveryReport"] && params["DeliveryReport"]["message"]
        reports = params["DeliveryReport"]["message"]
        reports = [reports] unless reports.is_a?(Array)
        reports.each do |report|
          processable_array << {'msg_id' => report['id'], 'status' => report['status']}
        end
      end

      return processable_array
    end

    def self.after_gateway_commit(delivery_reports)
      return true
    end

  end

  setup do
    ActionSmser.delivery_options[:gateway_commit_observers] = []
  end

  test "gateway_commit with existing dr" do
    @msg_id = "102010314204056202"
    @dr = ActionSmser::DeliveryReport.create(:msg_id => @msg_id, :status => 'ORIGINAL_STATUS')

    ActionSmser.delivery_options[:gateway_commit] = {'test_gateway' => SmsTestSetup}
    ActionSmser.gateway_commit_observer_add(SmsTestSetup)

    SmsTestSetup.expects(:after_gateway_commit).once.with(){|var| var.is_a?(Array) && var.first.is_a?(ActionSmser::DeliveryReport)}

    get 'gateway_commit', :use_route => :action_smser, :gateway => 'test_gateway',
        "DeliveryReport"=>{"message"=>{"id"=>@msg_id, "donedate"=>"2012/01/03 14:20:45", "sentdate"=>"2012/01/03 14:20:40", "status"=>"DELIVERED"}}


    assert_response :success
    assert @response.body.downcase.include?("update"), "should have responsed about saving"
    @dr.reload
    assert_equal "DELIVERED", @dr.status
  end

  test "gateway_commit with multiple records" do
    @msg_id = "102010314204056202"
    @msg_id2 = "99999999999999999"
    @dr = ActionSmser::DeliveryReport.create(:msg_id => @msg_id, :status => 'ORIGINAL_STATUS')
    @dr2 = ActionSmser::DeliveryReport.create(:msg_id => @msg_id2, :status => 'ORIGINAL_STATUS')

    ActionSmser.delivery_options[:gateway_commit] = {'test_gateway' => SmsTestSetup}

    get 'gateway_commit', :use_route => :action_smser, :gateway => 'test_gateway',
        "DeliveryReport"=>
            {"message"=>[{"id"=>@msg_id.to_s, "status"=>"DELIVERED"},
                         {"id"=>@msg_id2, "status"=>"DELIVERED"}]}

    assert_response :success
    assert @response.body.downcase.include?("update"), "should have responded about saving"
    @dr.reload
    @dr2.reload
    assert_equal "DELIVERED", @dr.status, "should have updated first record"
    assert_equal "DELIVERED", @dr2.status, "should have updated second record"
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


  test "index with forbidden admin_access (default access mode)" do
    get 'index', :use_route => :action_smser
    assert_response 403
    assert_template nil
  end

  test "index with admin_access lambda with right login info" do
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


  test "index with always enabled admin" do
    2.times do
      ActionSmser::DeliveryReport.create(:msg_id => "idtest_#{rand(10)}")
    end
    ActionSmser::DeliveryReportsController.any_instance.stubs(:admin_access_only).returns(true)
    get 'index', :use_route => :action_smser
    assert_response :success
    assert_template :index
  end

  test "list with always enabled admin" do
    2.times do
      ActionSmser::DeliveryReport.create(:msg_id => "idtest_#{rand(10)}")
    end
    ActionSmser::DeliveryReportsController.any_instance.stubs(:admin_access_only).returns(true)
    get 'list', :use_route => :action_smser
    assert_response :success
    assert_template :list
  end



end
