# encoding: utf-8
require 'cgi'
require 'iconv'

class ActionSmser::Base

  # This is the main class that your sms mailers will inherit.
  class << self
    def method_missing(method, *args) #:nodoc:
      return super unless respond_to?(method)
      new(method, *args)
    end

    def respond_to?(method, include_private = false) #:nodoc:
      #super || public_instance_methods(true).include?(method.to_s)
      super || method_defined?(method.to_sym)
    end

    # http://en.wikipedia.org/wiki/GSM_03.38 , some chars takes 2 spaces
    SMS_DOUBLE_CHARS = '€[\]^{|}~'   # http://sites.google.com/site/freesmsuk/gsm7-encoding
    def message_real_length(message)
      i = 0
      message.to_s.chars.each do |char| i += SMS_DOUBLE_CHARS.include?(char) ? 2 : 1 end
      i
    end
    # Make sure that double chars are taken account
    def message_real_cropped(message, max_length = 159)
      result = ""
      length = 0
      message.to_s.chars.each do |char|
        length += SMS_DOUBLE_CHARS.include?(char) ? 2 : 1
        result << char if length <= max_length
      end
      result
    end


  end

  ##################################################################
  ## INSTANCE METHODS

  attr_accessor :body, :to, :from

  # Initialized to duplicate of ActionSmser.delivery_options
  attr_accessor :delivery_options

  # Delivery methods can use this to save data for debugging, e.g. http responses etc
  attr_accessor :delivery_info

  # sms_type is string "ClassName.ActionName", initialized in beginning
  def sms_type
    "#{self.class}.#{@sms_action}"
  end

  # Called from class.method_missing with own_sms_message when you call OwnMailer.own_sms_message
  def initialize(method_name, *args)
    @delivery_options = ActionSmser.delivery_options.dup
    @valid = true
    @sms_action = method_name
    send method_name, *args
  end

  # Main method for creating sms infos
  def sms(options)
    @body = options[:body]
    @to = options[:to]
    @from = options[:from]
    self
  end

  def to_s
    "Sms #{sms_type} - From: #{from.inspect}, To: #{to.inspect}, Body: #{body.inspect}, Valid: #{@valid}"
  end

  def valid?
    !body.blank? && !from.blank? && !to_numbers_array.collect{|number| number.to_s.blank? ? nil : true}.compact.blank?
  end

  def delivery_method
    ActionSmser::DeliveryMethods.const_get(delivery_options[:delivery_method].to_s.downcase.camelize)
  end


  def deliver
    return false unless valid?

    logger.info "Sending sms (#{self.to_s})"

    response = delivery_method.deliver(self) if valid?

    self.send(:after_delivery, response) if self.respond_to?(:after_delivery)

    response
    #SmsSentInfo.create_from_http_response(@response, self.sender, recipients_receive_sms, sms_type, self.message)
  end

  # Most of the gateways want escaped and ISO encoded messages
  # Also make sure that its max 500 chars long
  def body_encoded_escaped
    msg = body.first(500)
    CGI.escape(Iconv.iconv('ISO-8859-15//TRANSLIT//IGNORE', 'utf-8', msg).first.to_s)
  end

  # make sure that to is an array and remove leading '+' or '0' chars
  def to_numbers_array
    array = if @to.is_a?(Array)
      @to.collect{|number| number.to_s}
    else
      [@to.to_s]
    end
    array.collect{|number| number.gsub(/^(\+|0)/, "")}
  end

  def to_as_array
    @to.is_a?(Array) ? @to : [@to]
  end

  def to_encoded
    to_numbers_array.join(",")
  end

  def from_encoded
    @from
  end

  def logger
    ActionSmser::Logger
  end


end

