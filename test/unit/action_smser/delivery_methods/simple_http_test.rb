# encoding: utf-8
require 'test_helper'

class ActionSmser::SimpleHttpTest < ActiveSupport::TestCase
  class MockSms<ActionSmser::Base
    def basic_sms(to, from, body)
      sms(:to => to, :from => from, :body => body)
    end
  end

  setup do
    @receivers = ["555123555", "123555123"]
    @sender = "555666"
    @body = "Body with ääkköset end"
    @sms = MockSms.basic_sms(@receivers, @sender, @body)

    @sms.delivery_options[:delivery_method] = :simple_http
    @sms.delivery_options[:simple_http] = {:username => 'user', :password => 'pass'}
    assert_equal ActionSmser::DeliveryMethods::SimpleHttp, @sms.delivery_method, "cant run tests, wrong delivery method"

    http_mock = stub(:body => "id_1234\nid_6666")
    ActionSmser::DeliveryMethods::SimpleHttp.stubs(:deliver_http_request).returns(http_mock)

  end

  test "should be able to deliver" do
    @sms_delivery = @sms.deliver
    assert @sms_delivery
    assert_equal @sms_delivery.count, 2, "two messages"
  end

  test "with saving delivery_reports" do
    @sms.delivery_options[:save_delivery_reports] = true
    #debugger
    @delivery_reports_count = ActionSmser::DeliveryReport.count
    @sms_delivery = @sms.deliver

    assert @sms_delivery.is_a?(Array)
    assert @sms_delivery.first.is_a?(ActionSmser::DeliveryReport), "should return deliveryreport array"

    assert_equal @delivery_reports_count + 2, ActionSmser::DeliveryReport.count

    @dr = @sms_delivery.last
    assert_equal "123555123", @dr.to, "receiver wrong"
    assert_equal "id_6666", @dr.msg_id, "id wrong"
  end

end
