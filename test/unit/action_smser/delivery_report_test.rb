# encoding: utf-8
require 'test_helper'

class ActionSmser::DeliveryReportTest < ActiveSupport::TestCase

  class MockSms<ActionSmser::Base
    def basic_sms(to, from, body)
      sms(:to => to, :from => from, :body => body)
    end
  end

  setup do
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

end
