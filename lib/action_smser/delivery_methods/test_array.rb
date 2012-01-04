module ActionSmser::DeliveryMethods

  # Default delivery method for test environments.
  # Saves delivered sms to ActionSmser::DeliveryMethods::TestArray.deliveries to help test your own software
  # Normal array, see sms by 'ActionSmser::DeliveryMethods::TestArray.deliveries' and
  # clear it between tests by 'ActionSmser::DeliveryMethods::TestArray.deliveries.clear'
  class TestArray
    @@deliveries = []
    def self.deliveries
      @@deliveries
    end

    def self.deliver(sms)
      ActionSmser::Logger.info "ActionSmser::DeliveryMethods::TestArray.deliveries added message, no real delivery."
      self.deliveries << sms

      if sms.delivery_options[:save_delivery_reports]
        delivery_reports = []
        sms.to_numbers_array.each do |to|
          delivery_reports << ActionSmser::DeliveryReport.create_from_sms(sms, to, "test_array_id_#{rand(99999999)}")
        end
        delivery_reports
      else
        return sms.to_numbers_array
      end

    end

  end
end
