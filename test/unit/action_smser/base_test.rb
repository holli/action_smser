require 'test_helper'

require 'minitest/autorun'

#class ActionSmser::BaseTest < ActiveSupport::TestCase

class MockSms<ActionSmser::Base
  def basic_sms(to, from, body)
    sms(:to => to, :from => from, :body => body)
  end

  def hello_world()
    sms(:to => "1234", :from => '1234', :body => 'hello world')
  end
end


describe ActionSmser::Base do
  before do
    @receivers = ["555123555", "", "123555123"]
    @sender = "555666"
    @body = "Body with ääkköset end"
    @sms = MockSms.basic_sms(@receivers, @sender, @body)
  end

  it "receivers should be joined by commas" do
    @sms.to_encoded.must_equal "555123555,123555123"
  end

  it "body should be possible to encode" do
    @sms.body_encoded_escaped.must_equal "Body+with+%E4%E4kk%F6set+end"
  end

  it "should be valid sms" do
    assert @sms.valid?, @sms
  end

  describe "delivery" do

    it "should have test_array as delivery method" do
      assert_equal ActionSmser::DeliveryMethods::TestArray, @sms.delivery_method
    end

    describe "test_array delivery" do
      before do
        ActionSmser::DeliveryMethods::TestArray.deliveries.clear
        @sms_delivery = @sms.deliver
      end
      
      it "should be able to deliver" do
        assert @sms_delivery
      end
      it "should add to TestArray" do
        assert_equal 1, ActionSmser::DeliveryMethods::TestArray.deliveries.size
        assert_equal @sms, ActionSmser::DeliveryMethods::TestArray.deliveries.first
      end
    end
  end

end
