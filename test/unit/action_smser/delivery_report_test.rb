# encoding: utf-8
require 'test_helper'

class ActionSmser::DeliveryReportTest < ActiveSupport::TestCase

  class MockSms<ActionSmser::Base
    def basic_sms(to, from, body)
      sms(:to => to, :from => from, :body => body)
    end
  end

  setup do
    ActionSmser.delivery_options[:save_delivery_reports] = false
    @receivers = ["555123555", "", "123555123"]
    @sender = "555666"
    @body = "Body with ääkköset end"
    @sms = MockSms.basic_sms(@receivers, @sender, @body)
  end

  test "build DeliveryReport from sms" do
    @dr = ActionSmser::DeliveryReport.build_from_sms(@sms, "123", "msg_id_a")

    assert @sender == @dr.from, "should have set @sms.from"
    assert @body == @dr.body, "should have set @sms.body"
    assert @sms.sms_type == @dr.sms_type, "should have set @sms.sms_type"

    assert "123" == @dr.to, "should have set right to info"

    assert "msg_id_a" == @dr.msg_id, "should have set right msg_id"

  end

  test "create_from_save" do
    @dr_count = ActionSmser::DeliveryReport.count
    @dr = ActionSmser::DeliveryReport.create_from_sms(@sms, "123", "msg_id_a")

    assert_equal @dr_count + 1, ActionSmser::DeliveryReport.count, "should have created one in db"
    assert @dr.is_a?(ActionSmser::DeliveryReport), "should have returned right item"
  end


  test "updating status" do
    @dr = ActionSmser::DeliveryReport.new
    @dr.status = "LOCAL_TEST"
    @dr.save!
    log = @dr.log

    @dr.status = "TEST_2"
    assert_equal "TEST_2", @dr.status
    assert log != @dr.log, "should have updated log"
    assert @dr.log.include?("TEST_2")
    assert @dr.save
  end

  test "to_sms" do
    @dr = ActionSmser::DeliveryReport.create_from_sms(@sms, "123", "msg_id_a")

    @dr = ActionSmser::DeliveryReport.find(@dr.id)
    new_sms = @dr.to_sms

    assert_equal @sender, @dr.from, "from info wrong"
    assert_equal "123", @dr.to, "to info wrong"
    assert_equal @body, @dr.body, "body info wrong"
    assert_equal @sms.sms_type, @dr.sms_type
  end

  test "re_deliver with simple_http" do
    ActionSmser.delivery_options[:save_delivery_reports] = true

    @dr = ActionSmser::DeliveryReport.create_from_sms(@sms, "123", "msg_id_a")
    @dr.gateway = "some_delivery"
    @dr.save

    @dr = ActionSmser::DeliveryReport.find(@dr.id)

    result = @dr.re_deliver(:test_array)

    assert @dr.re_delivered
    assert ActionSmser::DeliveryReport.find(@dr.id).re_delivered?

    assert result.is_a?(Array)
    assert result.first.is_a?(ActionSmser::Base)
    assert result.second.is_a?(Array)
    assert result.second.first.is_a?(ActionSmser::DeliveryReport)

    @dr_resent = ActionSmser::DeliveryReport.last

    assert_equal @sender, @dr_resent.from, "from info wrong"
    assert_equal "#{@sms.sms_type}_resent", @dr_resent.sms_type

    assert_equal @dr.id, @dr_resent.re_delivery_of_delivery_report_id, "should set new reports re_delivery_of_delivery_report_id"
    assert_equal @dr.re_deliveries.first, @dr_resent
    assert_equal @dr, @dr_resent.re_delivery_of
  end


end

