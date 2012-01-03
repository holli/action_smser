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
        puts("FIXME: HERE SHOULD BE DELIVERY_INFO SAVE")
        puts "TEE SE VAIKKA LAITTAMALLA DELIVERYREPORT OTTAMAAN INITIALIZESSA SMS RESPONSEA"

      else
        return sms.to.to_a.size
      end

    end

  end
end
