require 'test_helper'

class ActionSmser::TestArrayTest < ActiveSupport::TestCase
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

    @sms.delivery_options[:delivery_method] = :test_array
    assert_equal ActionSmser::DeliveryMethods::TestArray, @sms.delivery_method, "cant run tests, wrong delivery method"
    ActionSmser::DeliveryMethods::TestArray.deliveries.clear

    @sms_delivery = @sms.deliver
  end

  test "should be able to deliver" do
    assert @sms_delivery
  end

  test "should add to TestArray" do
    assert_equal 1, ActionSmser::DeliveryMethods::TestArray.deliveries.size
    assert_equal @sms, ActionSmser::DeliveryMethods::TestArray.deliveries.first
  end

  test "with saving delivery_reports" do
    ActionSmser::DeliveryMethods::TestArray.deliveries.clear
    @sms.delivery_options[:save_delivery_reports] = true
    @delivery_reports_count = ActionSmser::DeliveryReport.count
    @sms_delivery = @sms.deliver

    assert_equal @delivery_reports_count + 2, ActionSmser::DeliveryReport.count
  end

end
