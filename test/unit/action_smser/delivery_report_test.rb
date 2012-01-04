require 'test_helper'

#require 'minitest/autorun'
#
#class MockSms<ActionSmser::Base
#  def basic_sms(to, from, body)
#    sms(:to => to, :from => from, :body => body)
#  end
#end
#
#describe ActionSmser::DeliveryReport do
#  before do
#    @receivers = ["555123555", "", "123555123"]
#    @sender = "555666"
#    @body = "Body with ääkköset end"
#    @sms = MockSms.basic_sms(@receivers, @sender, @body)
#  end
#
#  describe "build DeliveryReport from sms" do
#    before do
#      @dr = ActionSmser::DeliveryReport.build_from_sms(@sms, "123", "msg_id_a")
#    end
#    it "should have set @sms params" do
#      assert_equal @sender, @dr.from
#      assert_equal @body, @dr.body
#      assert_equal @sms.sms_type, @dr.sms_type
#    end
#    it "should have set right to info" do
#      assert_equal "123", @dr.to
#    end
#    it "should have set right msg_id" do
#      assert_equal "msg_id_a", @dr.msg_id
#    end
#  end
#
#  describe "create_from_save" do
#    before do
#      @dr_count = ActionSmser::DeliveryReport.count
#      @dr = ActionSmser::DeliveryReport.create_from_sms(@sms, "123", "msg_id_a")
#    end
#    it "should have created one in db" do
#      assert_equal @dr_count + 1, ActionSmser::DeliveryReport.count
#    end
#    it "should have returned right item" do
#      assert @dr.is_a?(ActionSmser::DeliveryReport)
#    end
#  end
#
#end
