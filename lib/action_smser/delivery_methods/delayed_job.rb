begin
  require 'delayed_job'

  module ActionSmser::DeliveryMethods

    class DelayedJob

      def self.deliver(sms)
        ActionSmser::Logger.info "Delivering sms by delayed_job"

        sms.to_numbers_array.collect do |to|
          ::Delayed::Job.enqueue(SmsDeliverJob.new(sms, to), :queue => 'sms-deliver', :priority => sms.delivery_options[:delayed_job][:priority].to_i)
        end
      end

      class SmsDeliverJob < ActionSmser::Base

        def initialize(sms, to)
          [:body, :from, :sms_type, :re_delivery_of_delivery_report_id, :ttl, :delivery_options].each do |attr|
            self.send("#{attr}=", sms.send(attr).dup) unless sms.send(attr).nil?
          end
          self.send("to=", to)
          @valid = true
          self.delivery_options[:delivery_method] = sms.delivery_options[:delayed_job][:delivery_method]
        end

        def perform
          self.deliver
        end

      end

    end
  end

rescue LoadError => e

  module ActionSmser::DeliveryMethods
    class DelayedJob
      def self.deliver(sms)
        raise "ActionSmser::DeliveryMethods::DelayedJob: NO DELAYED JOB GEM INCLUDED, ADD DELAYED_JOB TO YOUR GEMFILE"
      end
    end
  end

end
