module ActionSmser::DeliveryMethods

  # Very simple implementation of http request to gateway. Options used are
  # server, use_ssl, username, password
  # overwrite deliver_path(sms, options) with your own if you have different type of path
  class SimpleHttp
    
    def self.deliver(sms)
      logger.info "Delivering sms by https"
      self.deliver_http(sms, sms.delivery_options[:simple_http])
    end

    def self.deliver_http(sms, options)
      # http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
      # http://notetoself.vrensk.com/2008/09/verified-https-in-ruby/

      deliver_path = self.deliver_path(sms, options)

      response = nil

      server_port = options[:use_ssl] ? 443 : 80
      http = Net::HTTP.new(options[:server], server_port)
      if options[:use_ssl]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      unless Rails.env.test?
        http.start do |http|
          response = http.request(Net::HTTP::Get.new(deliver_path)) unless Rails.env.test? #Never request by accident in test environment.
        end
      else
        logger.warn "SimpleHttp does never make real http requests in test environment!"
      end
      
      logger.info "SimpleHttp delivery ||| #{deliver_path} ||| #{response.inspect}"
      logger.info response.body if !response.blank?
      response
    end

    def self.deliver_path(sms, options)
      "/api/sendsms/plain?user=#{options[:username]}&password=#{options[:password]}&sender=#{sms.from_encoded}&SMSText=#{sms.body_encoded_escaped}&GSM=#{sms.to_encoded}"
    end

    def self.logger
      ActionSmser::Logger
    end

  end
end
