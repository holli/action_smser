require 'net/http'
require 'net/https'

module ActionSmser::DeliveryMethods

  # Very simple implementation of http request to gateway. Options used are
  # server, use_ssl, username, password
  # Also optional code (=unicode) is possible. See https://docs.nexmo.com/index.php/messaging-sms-api/send-message
  # overwrite deliver_path(sms, options) with your own if you have different type of path
  class Nexmo < SimpleHttp
    
    def self.deliver(sms)
      options = sms.delivery_options[:nexmo] || {}
      options = options.dup

      options[:server] = 'rest.nexmo.com'
      options[:use_ssl] = true
      options[:status_report_req] ||= sms.delivery_options[:save_delivery_reports]

      sms.delivery_info = []

      sms.to_numbers_array.each do |to|
        deliver_path = self.deliver_path(sms, to, options)
        response = self.deliver_http_request(sms, options, deliver_path)

        logger.info "Nexmo delivery http ||| #{deliver_path} ||| #{response.inspect}"
        logger.info response.body if !response.blank?

        sms.delivery_info.push(response)

        result = JSON.parse(response.body)["messages"].first

        # Results include sms_id or error code in each line
        if sms.delivery_options[:save_delivery_reports]
          dr = ActionSmser::DeliveryReport.build_from_sms(sms, to, result["message-id"])
          if result["status"].to_i > 0
            dr.status = "SENT_ERROR_#{result["status"]}"
            dr.log += "nexmo_error: #{result["error-text"]}"
          end
          dr.save
          sms.delivery_reports.push(dr)
        end
      end

      sms.delivery_options[:save_delivery_reports] ? sms.delivery_reports : sms.delivery_info
    end

    def self.deliver_path(sms, to, options)
      path = "/sms/json?username=#{options[:username]}&password=#{options[:password]}&ttl=#{sms.ttl_to_i*1000}&status-report-req=#{options[:status_report_req]}&from=#{sms.from_encoded}&to=#{to}&text=#{sms.body_escaped}"
      path += "&code=#{options[:code]}" if options[:code]
      path
    end

    # Callback message status handling
    # This has to return array of hashes. In hash msg_id is the key and other params are updated to db
    def self.process_delivery_report(params)
      processable_array = []
      if msg_id = params["messageId"]
        processable_array << {'msg_id' => params["messageId"], 'status' => params['status']}
      end
      return processable_array
    end

  end
end
