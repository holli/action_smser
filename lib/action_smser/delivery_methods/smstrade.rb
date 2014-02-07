require 'net/http'
require 'net/https'

module ActionSmser::DeliveryMethods

  # Documentation: http://www.smstrade.eu/pdf/SMS-Gateway_HTTP_API_v2_en.pdf
  class Smstrade < SimpleHttp
    ERROR_CODES = {
      "10" => "RECEIVER_INVALID",
      "20" => "SENDER_INVALID",
      "30" => "BODY_INVALID",
      "31" => "MESSAGE_TYPE_INVALID",
      "40" => "ROUTE_INVALID",
      "50" => "API_KEY_INVALID",
      "60" => "INSUFFICIENT_FUNDS",
      "70" => "ROUTE_NOT_SUPPORTED",
      "71" => "FEATURE_NOT_POSSIBLE",
      "80" => "HANDOVER_FAILED",
      "100" => "OK"
    }

    def self.deliver(sms)
      options = sms.delivery_options[:smstrade] || {}
      options = options.dup

      options[:server] = 'gateway.smstrade.de'
      options[:use_ssl] = false
      options[:status_report_req] ||= sms.delivery_options[:save_delivery_reports]

      sms.delivery_info = []

      sms.to_numbers_array.each do |to|
        deliver_path = self.deliver_path(sms, to, options)
        response = self.deliver_http_request(sms, options, deliver_path)

        ActionSmser::Logger.info "Smstrade delivery http ||| #{deliver_path} ||| #{response.inspect}"
        ActionSmser::Logger.info response.body if !response.blank?

        sms.delivery_info.push(response)

        result = response.body.split("\n")
        result = {"response-code" => result[0], "message-id" => result[1], "cost" => result[2], "message-count" => result[3]}

        if ERROR_CODES[result["response-code"]].nil?
          status = "UNKNOWN_ERROR"
        else
          status = ERROR_CODES[result["response-code"]]
        end

        # Results include sms_id or error code in each line
        if sms.delivery_options[:save_delivery_reports]
          dr = ActionSmser::DeliveryReport.build_from_sms(sms, to, result["message-id"])
          if status != "OK"
            dr.status = status
            dr.add_log "smstrade_error_code: #{result["response-code"]}"
          end
          dr.save
          sms.delivery_reports.push(dr)
        end
      end

      sms.delivery_options[:save_delivery_reports] ? sms.delivery_reports : sms.delivery_info
    end

    def self.deliver_path(sms, to, options)
      "/?key=#{options[:key]}"+
      "&from=#{sms.from_escaped}"+
      "&to=#{to}"+
      "&message=#{sms.body_escaped}"+
      "&route=#{options[:route]}"+
      "&debug=#{options[:debug] ? 1 : 0}"+
      "&cost=1&message_id=1&count=1&charset=utf-8"
    end
  end
end
