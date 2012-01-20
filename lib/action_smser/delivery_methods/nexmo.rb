require 'net/http'
require 'net/https'

module ActionSmser::DeliveryMethods

  # Very simple implementation of http request to gateway. Options used are
  # server, use_ssl, username, password
  # overwrite deliver_path(sms, options) with your own if you have different type of path
  class Nexmo < SimpleHttp
    
    def self.deliver(sms)
      logger.info "Delivering sms by https"

      options = sms.delivery_options[:nexmo] || {}

      options[:server] = 'rest.nexmo.com'
      options[:use_ssl] = true
      options[:ttl] ||= 60*1000
      options[:status_report_req] ||= sms.delivery_options[:save_delivery_reports]

      deliver_path = self.deliver_path(sms, options)

      response = self.deliver_http_request(sms, options, deliver_path)

      logger.info "SimpleHttp delivery ||| #{deliver_path} ||| #{response.inspect}"
      logger.info response.body if !response.blank?
      sms.delivery_info = response

      # Results include sms_id or error code in each line

      results = JSON.parse(response.body)["messages"]
      if sms.delivery_options[:save_delivery_reports]
        delivery_reports = []
        sms.to_numbers_array.each_with_index do |to, i|
          result = results[i]
          dr = ActionSmser::DeliveryReport.build_from_sms(sms, to, result["message-id"])
          if result["status"].to_i > 0
            dr.status = "SENT_ERROR_#{result["status"]}"
            dr.log += "nexmo_error: #{result["error-text"]}"
          end
          dr.save

          delivery_reports << dr
        end
        return delivery_reports
      else
        return results
      end

    end

    def self.deliver_path(sms, options)
      "/sms/json?username=#{options[:username]}&password=#{options[:password]}&ttl=#{options[:ttl]}&status-report-req=#{options[:status_report_req]}&from=#{sms.from_encoded}&to=#{sms.to_encoded}&text=#{sms.body_escaped}"
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
