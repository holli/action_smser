
# FIXME: PUT THESE IN GEM FILE
#require 'net/http'
#require 'iconv'

module ActionSmser
  class Base

    class << self

      # In test environment this includes delivered sms messages for verifying how your software works
      # Normal array, see messages by 'ActionSmser.deliveries' and clear by 'ActionSmser.deliveries.clear'
      @@deliveries = []
      def deliveries
        @@deliveries
      end
      def deliveries_add(sms)
        self.deliveries << sms
      end

      
      def method_missing(method, *args) #:nodoc:
        return super unless respond_to?(method)
        new(method, *args)
      end

      def respond_to?(method, include_private = false) #:nodoc:
        super || public_instance_methods(true).include?(method.to_s)
      end
    end

    # Called from class.method_missing with own_sms_message when you call OwnMailer.own_sms_message
    def initialize(method_name, *args)
      @valid = true
      @sms_action = method_name
      send method_name, *args
    end

    # Main method for creating sms infos
    def sms(options)
      @body = options[:body]
      @to = options[:to]
      @from = options[:from]
    end

    def to_s
      "Sms #{self.class}.#{@sms_action} - From: #{@from}, To: #{@to}, Body: #{@body}, Valid: #{@valid}"
    end

    # If you want mark the message as invalid
    def set_invalid
      @valid = false
    end

    def deliver

      self.class.deliveries_add(self)
      Logger.info "sent sms (#{self.to_s})"
    end

    def deliver_https(deliver_path)
    end


    # Only send messages in production
    def self.deliver_messages?
      Rails.env.production? || Rails.env.development?
    end

  end

  class Logger
    def self.info(str)
      Rails.logger.info("ActionSmser: #{str}")
    end
    def self.warn(str)
      Rails.logger.warn("ActionSmser: #{str}")
    end
  end


end
