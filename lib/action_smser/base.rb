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
  end

  def to_s
    "Sms #{sms_type} - From: #{from.inspect}, To: #{to.inspect}, Body: #{body.inspect}, Valid: #{@valid}"
  end

  # If you want mark the message as invalid
  def set_invalid
    @valid = false
  end

  def valid?
    @valid && !body.blank? && !@to.blank? && !@from.blank?
  end

  def delivery_method
    ActionSmser::DeliveryMethods.const_get(delivery_options[:delivery_method].to_s.downcase.camelize)
  end


  def deliver
    return false unless valid?

    logger.info "Sending sms (#{self.to_s})"

    response = delivery_method.deliver(self)

    self.send(:after_delivery, response) if self.respond_to?(:after_delivery)

    response
    #SmsSentInfo.create_from_http_response(@response, self.sender, recipients_receive_sms, sms_type, self.message)
  end

  # http://en.wikipedia.org/wiki/GSM_03.38 , some chars takes 2 spaces
  def body_length
    i = 0
    body.to_s.chars.each do |char| i += DOUBLE_CHARS.include?(char) ? 2 : 1 end
    i
  end
  def body_cropped(max_length = 159)
    result = ""
    length = 0
    msg.to_s.chars.each do |char|
      length += DOUBLE_CHARS.include?(char) ? 2 : 1
      result << char if length <= max_length
    end
    result
  end
  # Most of the gateways want escaped and ISO encoded messages
  def body_encoded_escaped(cropped = true)
    message = (cropped ? body : body_cropped)
    CGI.escape(Iconv.iconv('ISO-8859-15//TRANSLIT//IGNORE', 'utf-8', message).first.to_s)
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

