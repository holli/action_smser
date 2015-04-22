# encoding: utf-8
require 'test_helper'

class ActionSmser::SmstradeTest < ActiveSupport::TestCase
  class MockSms < ActionSmser::Base
    def basic_sms(to, from, body)
      sms(:to => to, :from => from, :body => body)
    end
  end

  setup do
    @receivers = ["4915112341234", "4917812341234"]
    @sender = "4917212341234"
    @body = "Body with ümläüts."
    @sms = MockSms.basic_sms(@receivers, @sender, @body)

    @sms.delivery_options[:delivery_method] = :smstrade
    @sms.delivery_options[:smstrade] = {:key => 'api-key-here', :route => 'gold', :debug => true}
    assert_equal ActionSmser::DeliveryMethods::Smstrade, @sms.delivery_method, "cant run tests, wrong delivery method"

    @http_mock = stub(:body => "100\n123456789\n0.064\n1")
    ActionSmser::DeliveryMethods::Smstrade.stubs(:deliver_http_request).returns(@http_mock)
  end

  test "should be able to deliver" do
    ActionSmser::DeliveryMethods::Smstrade.expects(:deliver_http_request).twice().returns(@http_mock)
    @sms_delivery = @sms.deliver
    assert @sms_delivery
    assert_equal 2, @sms_delivery.count
  end

  test "should only receive numbers not prepended with zeros or plus signs" do
    prepended_receivers = ["004915112341234", "+4917812341234", "04917332341111"]
    sms = MockSms.basic_sms(prepended_receivers, @sender, @body)

    assert_equal ["4915112341234", "4917812341234", "4917332341111"], sms.to_numbers_array
  end

  test "should append 00 to phone numbers before sending" do
    @receivers.each do |to|
      ActionSmser::DeliveryMethods::Smstrade.expects(:deliver_path).with(anything(), "00#{to}", anything())
    end

    sms_delivery = @sms.deliver
  end

  test "with saving delivery_reports" do
    @sms.delivery_options[:save_delivery_reports] = true
    @delivery_reports_count = ActionSmser::DeliveryReport.count

    ActionSmser::DeliveryMethods::Smstrade.stubs(:deliver_http_request).returns(@http_mock)

    @sms_delivery = @sms.deliver

    assert @sms_delivery.is_a?(Array)
    assert @sms_delivery.first.is_a?(ActionSmser::DeliveryReport), "should return delivery report array"

    assert_equal @delivery_reports_count + 2, ActionSmser::DeliveryReport.count, "should have saved 2 delivery reports"

    @dr1 = @sms_delivery.first
    assert_equal "smstrade", @dr1.gateway
    assert_equal "004915112341234", @dr1.to, "receiver wrong"
    assert_equal "LOCAL_SENT", @dr1.status

    @dr2 = @sms_delivery.last
    assert_equal "004917812341234", @dr2.to, "receiver wrong"
  end
end
