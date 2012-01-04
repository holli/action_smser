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

end
