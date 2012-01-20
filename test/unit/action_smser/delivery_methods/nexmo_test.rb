# encoding: utf-8
require 'test_helper'

class ActionSmser::NexmoTest < ActiveSupport::TestCase
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

    @sms.delivery_options[:delivery_method] = :nexmo
    @sms.delivery_options[:nexmo] = {:username => 'user', :password => 'pass'}
    assert_equal ActionSmser::DeliveryMethods::Nexmo, @sms.delivery_method, "cant run tests, wrong delivery method"

    http_mock = stub(
        :body => '{"message-count":"1","messages":[{"message-price":"0.02500000","status":"0","message-id":"0778DE88","remaining-balance":"1.77500000"}]}')
    ActionSmser::DeliveryMethods::Nexmo.stubs(:deliver_http_request).returns(http_mock)
  end

  test "should be able to deliver" do
    @sms_delivery = @sms.deliver
    assert @sms_delivery
    assert_equal 1, @sms_delivery.count
  end

  test "with saving delivery_reports" do
    @sms.delivery_options[:save_delivery_reports] = true
    @delivery_reports_count = ActionSmser::DeliveryReport.count

    http_mock = stub(
        :body => '{"message-count":"1","messages":[{"message-price":"0.02500000","status":"0","message-id":"0778DE88","remaining-balance":"1.77500000"},{"error-text":"Message rejected by upstream path","message-price":"0.02500000","status":"6","message-id":"0778D302","remaining-balance":"1.87500000"}]}')
    ActionSmser::DeliveryMethods::Nexmo.stubs(:deliver_http_request).returns(http_mock)

    @sms_delivery = @sms.deliver

    assert @sms_delivery.is_a?(Array)
    assert @sms_delivery.first.is_a?(ActionSmser::DeliveryReport), "should return delivery report array"

    assert_equal @delivery_reports_count + 2, ActionSmser::DeliveryReport.count, "should have saved 2 delivery reports"

    @dr1 = @sms_delivery.first
    assert_equal "nexmo", @dr1.gateway
    assert_equal "555123555", @dr1.to, "receiver wrong"
    assert_equal "LOCAL_SENT", @dr1.status

    @dr2 = @sms_delivery.last
    assert_equal "123555123", @dr2.to, "receiver wrong"
    assert_equal "0778D302", @dr2.msg_id, "id wrong"
    assert_equal "SENT_ERROR_6", @dr2.status
  end

  test "gateway process_delivery_report(params)" do
    @msg_id = "msg_id_asdf"

    result_array = ActionSmser::DeliveryMethods::Nexmo.process_delivery_report(
        {"messageId" => @msg_id, "status" => "EXPIRED"} )

    assert_equal @msg_id, result_array.first['msg_id']
    assert_equal "EXPIRED", result_array.first['status']

  end


  # curl -is "http://rest.nexmo.com/sms/json?username=...&password=...&from=ActionSmser&to=...&text=msg"
  NEXMO_ERROR_RESPONSE_BODY='{"message-count":"1","messages":[{"error-text":"Message rejected by upstream path","message-price":"0.02500000","status":"6","message-id":"0778D302","remaining-balance":"1.87500000"}]}'
  NEXMO_ERROR_RESPONSE=<<eos
HTTP/1.1 200 OK
Cache-Control: max-age=1
Content-Type: application/json;charset=ISO-8859-1
Transfer-Encoding: chunked
Server: Jetty(7.5.1.v20110908)

{"message-count":"1","messages":[{"error-text":"Message rejected by upstream path","message-price":"0.02500000","status":"6","message-id":"0778D302","remaining-balance":"1.87500000"}]}
eos
  NEXMO_OK_RESPONSE_BODY='{"message-count":"1","messages":[{"message-price":"0.02500000","status":"0","message-id":"0778DE88","remaining-balance":"1.77500000"}]}'
  NEXMO_OK_RESPONSE=<<eos
HTTP/1.1 200 OK
Cache-Control: max-age=1
Content-Type: application/json;charset=ISO-8859-1
Transfer-Encoding: chunked
Server: Jetty(7.5.1.v20110908)

{"message-count":"1","messages":[{"message-price":"0.02500000","status":"0","message-id":"0778DE88","remaining-balance":"1.77500000"}]}
eos


end
