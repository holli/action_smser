require 'net/http'
require 'net/https'

module ActionSmser::DeliveryMethods

  # Very simple implementation of http request to gateway. Options used are
  # server, use_ssl, username, password
  # overwrite deliver_path(sms, options) with your own if you have different type of path
  class SimpleHttp
    
    def self.deliver(sms)
      logger.info "Delivering sms by https"

      options = sms.delivery_options[:simple_http]
      deliver_path = self.deliver_path(sms, options)
      response = self.deliver_http_request(sms, options, deliver_path)

      logger.info "SimpleHttp delivery ||| #{deliver_path} ||| #{response.inspect}"
      logger.info response.body if !response.blank?
      sms.delivery_info = response

      # Results include sms_id or error code in each line

      results = response.body.split("\n")
      if sms.delivery_options[:save_delivery_reports]
        delivery_reports = []
        sms.to_numbers_array.each_with_index do |to, i|
          delivery_reports << ActionSmser::DeliveryReport.create_from_sms(sms, to, results[i])
        end
        return delivery_reports
      else
        return results
      end



    end

    def self.deliver_http_request(sms, options, path)
      # http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
      # http://notetoself.vrensk.com/2008/09/verified-https-in-ruby/

      response = nil
      
      server_port = options[:use_ssl] ? 443 : 80
      http = Net::HTTP.new(options[:server], server_port)
      if options[:use_ssl]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      unless Rails.env.test?
        http.start do |http|
          response = http.request(Net::HTTP::Get.new(path)) unless Rails.env.test? #Never request by accident in test environment.
        end
      else
        logger.warn "SimpleHttp does never make real http requests in test environment!"
      end

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
