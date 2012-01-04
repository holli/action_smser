require 'test_helper'

class ActionSmser::BaseTest < ActiveSupport::TestCase
  class MockSms<ActionSmser::Base
    def basic_sms(to, from, body)
      sms(:to => to, :from => from, :body => body)
    end

    def hello_world()
      sms(:to => "1234", :from => '1234', :body => 'hello world')
    end
  end

  setup do
    @receivers = ["555123555", "", "123555123"]
    @sender = "555666"
    @body = "Body with ääkköset end"
    @sms = MockSms.basic_sms(@receivers, @sender, @body)
  end

  test "receivers should be joined by commas" do
    assert_equal "555123555,123555123", @sms.to_encoded
  end

  test "body should be possible to encode" do
    assert_equal "Body+with+%E4%E4kk%F6set+end", @sms.body_encoded_escaped
  end

  test "should be valid sms" do
    assert @sms.valid?
  end

  

  #it "should have saved sms_type" do
  #  assert_equal "MockSms.basic_sms", @sms.sms_type
  #end
  #
  #it "should have copied the delivery_options when initializing" do
  #  assert @sms.delivery_options == ActionSmser.delivery_options
  #  assert @sms.delivery_options.object_id != ActionSmser.delivery_options.object_id
  #end
  #
  #describe "delivery" do
  #
  #  it "should have test_array as delivery method" do
  #    assert_equal ActionSmser::DeliveryMethods::TestArray, @sms.delivery_method
  #  end
  #
  #  describe "test_array delivery" do
  #    before do
  #      ActionSmser::DeliveryMethods::TestArray.deliveries.clear
  #      @sms_delivery = @sms.deliver
  #    end
  #
  #    it "should be able to deliver" do
  #      assert @sms_delivery
  #    end
  #
  #    it "should add to TestArray" do
  #      assert_equal 1, ActionSmser::DeliveryMethods::TestArray.deliveries.size
  #      assert_equal @sms, ActionSmser::DeliveryMethods::TestArray.deliveries.first
  #    end
  #
  #  end
  #
  #  describe "test_array delivery with saving delivery_reports" do
  #    before do
  #      ActionSmser::DeliveryMethods::TestArray.deliveries.clear
  #      @sms.delivery_options[:save_delivery_reports] = true
  #      @delivery_reports_count = ActionSmser::DeliveryReport.count
  #      @sms_delivery = @sms.deliver
  #    end
  #
  #    it "should have created two delivery_reports" do
  #      assert_equal @delivery_reports_count + 1, ActionSmser::DeliveryReport.count
  #    end
  #  end
  #end

end


#describe ActionSmser::Base do
#  before do
#
#  end
#
#  it "receivers should be joined by commas" do
#    @sms.to_encoded.must_equal "555123555,123555123"
#  end
#
#  it "body should be possible to encode" do
#    @sms.body_encoded_escaped.must_equal "Body+with+%E4%E4kk%F6set+end"
#  end
#
#  it "should be valid sms" do
#    assert @sms.valid?, @sms
#  end
#
#  it "should have saved sms_type" do
#    assert_equal "MockSms.basic_sms", @sms.sms_type
#  end
#
#  it "should have copied the delivery_options when initializing" do
#    assert @sms.delivery_options == ActionSmser.delivery_options
#    assert @sms.delivery_options.object_id != ActionSmser.delivery_options.object_id
#  end
#
#  describe "delivery" do
#
#    it "should have test_array as delivery method" do
#      assert_equal ActionSmser::DeliveryMethods::TestArray, @sms.delivery_method
#    end
#
#    describe "test_array delivery" do
#      before do
#        ActionSmser::DeliveryMethods::TestArray.deliveries.clear
#        @sms_delivery = @sms.deliver
#      end
#
#      it "should be able to deliver" do
#        assert @sms_delivery
#      end
#
#      it "should add to TestArray" do
#        assert_equal 1, ActionSmser::DeliveryMethods::TestArray.deliveries.size
#        assert_equal @sms, ActionSmser::DeliveryMethods::TestArray.deliveries.first
#      end
#
#    end
#
#    describe "test_array delivery with saving delivery_reports" do
#      before do
#        ActionSmser::DeliveryMethods::TestArray.deliveries.clear
#        @sms.delivery_options[:save_delivery_reports] = true
#        @delivery_reports_count = ActionSmser::DeliveryReport.count
#        @sms_delivery = @sms.deliver
#      end
#
#      it "should have created two delivery_reports" do
#        assert_equal @delivery_reports_count + 1, ActionSmser::DeliveryReport.count
#      end
#    end
#  end
#
##end
