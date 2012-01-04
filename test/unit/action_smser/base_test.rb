require 'test_helper'

class ActionSmser::BaseTest < ActiveSupport::TestCase
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

  test "receivers should be joined by commas" do
    assert_equal "555123555,123555123", @sms.to_encoded
  end

  test "body should be possible to encode" do
    assert_equal "Body+with+%E4%E4kk%F6set+end", @sms.body_encoded_escaped
  end

  test "should be valid sms" do
    assert @sms.valid?
  end

  test "should have saved sms_type" do
    assert_equal "ActionSmser::BaseTest::MockSms.basic_sms", @sms.sms_type
  end

  test "should have copied the delivery_options when initializing" do
    assert @sms.delivery_options == ActionSmser.delivery_options
    assert @sms.delivery_options.object_id != ActionSmser.delivery_options.object_id
  end

  test "should have test_array as delivery method" do
    assert_equal ActionSmser::DeliveryMethods::TestArray, @sms.delivery_method
  end

  ##############################################################
  ## DELIVERY WITH TEST_ARRAY

  def setup_delivery_with_test_array
    ActionSmser::DeliveryMethods::TestArray.deliveries.clear
    @sms_delivery = @sms.deliver
  end

  test "test_array should be able to deliver" do
    setup_delivery_with_test_array
    assert @sms_delivery
  end

  test "test_array should add to TestArray" do
    setup_delivery_with_test_array
    assert_equal 1, ActionSmser::DeliveryMethods::TestArray.deliveries.size
    assert_equal @sms, ActionSmser::DeliveryMethods::TestArray.deliveries.first
  end

  test "test_array delivery with saving delivery_reports" do
    ActionSmser::DeliveryMethods::TestArray.deliveries.clear
    @sms.delivery_options[:save_delivery_reports] = true
    @delivery_reports_count = ActionSmser::DeliveryReport.count
    @sms_delivery = @sms.deliver

    assert_equal @delivery_reports_count + 2, ActionSmser::DeliveryReport.count
  end

end
