# encoding: utf-8
require 'test_helper'

class ActionSmser::BaseTest < ActiveSupport::TestCase
  class MockSms<ActionSmser::Base
    def basic_sms(to, from, body)
      sms(:to => to, :from => from, :body => body)
    end

    def after_delivery(result)
      puts "generic delivery observer, mock this"
    end
  end

  setup do
    @receivers = ["555123555", "123", "+358123555123"]
    @sender = "555666"
    @body = "Body with ääkköset end"
    @sms = MockSms.basic_sms(@receivers, @sender, @body)
  end

  test "receivers should be joined by commas" do
    assert_equal "555123555,123,358123555123", @sms.to_encoded
  end

  test "should be ok with single receivers" do
    str = "123123"
    @sms = MockSms.basic_sms(str, @sender, @body)
    assert_equal [str], @sms.to_as_array
  end

  test "from_encoded should remove leading + and 0" do
    @sms = MockSms.basic_sms("+358555", "+358123" , @body)
    assert_equal "358123", @sms.from_encoded
  end

  test "body should be possible to encode" do
    assert_equal "Body+with+%E4%E4kk%F6set+end", @sms.body_encoded_escaped
  end

  test "body should be cropped to 500 chars, limit extra looong messages" do
    @sms.body = (1..1000).map{'a'}.join
    assert_equal 500, @sms.body_encoded_escaped.size
  end

  test "should be valid sms" do
    assert @sms.valid?
  end

  test "should not be valid if no recipients" do
    @sms = MockSms.basic_sms([nil, ""], @sender, @body)
    assert !@sms.valid?
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

  test "after delivery it should call delivery_observer if it's present" do
    @sms.expects(:after_delivery).once
    assert @sms.deliver
  end

  test "message_real_length should return real sms lenght" do
    assert_equal 4, ActionSmser::Base.message_real_length("a[a")
  end
  test "message_real_crop should return cropped message with sms chars taken account" do
    assert_equal "a[a[", ActionSmser::Base.message_real_cropped("a[a[", 6)
    assert_equal "a[a", ActionSmser::Base.message_real_cropped("a[a[", 5)
    assert_equal "a[a", ActionSmser::Base.message_real_cropped("a[a[", 4)
    assert_equal "a[", ActionSmser::Base.message_real_cropped("a[a[", 3)
  end

end
