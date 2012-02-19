# encoding: utf-8
require 'test_helper'

# We mock delayed_job
module Delayed
  class Job
  end
end

class ActionSmser::DelayedJobTest < ActiveSupport::TestCase
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

    @sms.delivery_options[:delivery_method] = :delayed_job
    @sms.delivery_options[:delayed_job] = {:delivery_method => :nexmo, :priority => 5}
    assert_equal ActionSmser::DeliveryMethods::DelayedJob, @sms.delivery_method, "cant run tests, wrong delivery method"
  end

  test "should be able to deliver and call enqueue for all receivers" do

    ::Delayed::Job.expects(:enqueue).twice().returns(1)
    @sms_delivery = @sms.deliver
    assert @sms_delivery
    assert_equal 2, @sms_delivery.count
  end

  test "test that serializing is ok" do
    smsdj = ActionSmser::DeliveryMethods::DelayedJob::SmsDeliverJob.new(@sms, @sms.to_numbers_array.first)

    [:body, :from, :sms_type, :re_delivery_of_delivery_report_id, :ttl, :delivery_info].each do |var|
      assert_equal smsdj.send(var), @sms.send(var)
    end

    assert smsdj.body.object_id != @sms.body.object_id, "It should make copy of all values, not use the same objects."

    assert_equal smsdj.delivery_options, @sms.delivery_options.merge(:delivery_method => @sms.delivery_options[:delayed_job][:delivery_method])
    
    assert_equal smsdj.to, @sms.to_numbers_array.first

    assert_equal :nexmo, smsdj.delivery_options[:delivery_method], "Should set the deliverymethod to nexmo"
    
  end

end
