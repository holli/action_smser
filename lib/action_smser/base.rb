
# FIXME: PUT THESE IN GEM FILE
require 'net/http'
require 'net/https'
require 'cgi'
require 'iconv'

class ActionSmser::Base

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

    # Only send messages in production
    def deliver_messages?
      Rails.env.production? || Rails.env.development?
    end

  end

  ##################################################################
  ## INSTANCE METHODS

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

  def valid?
    @valid && !body.blank? && !@to.blank? && !@from.blank?
  end

  
  def deliver
    return false unless valid?

    self.class.deliveries_add(self)
    logger.info "Sending sms (#{self.to_s})"

    @response = deliver_https

    #SmsSentInfo.create_from_http_response(@response, self.sender, recipients_receive_sms, sms_type, self.message)
  end

  def deliver_https
    # http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
    # http://notetoself.vrensk.com/2008/09/verified-https-in-ruby/

    response = nil
    if self.class.deliver_messages?

      https = Net::HTTP.new(ActionSmser.gateway[:server], 443)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      https.start do |http|
        response = http.request(Net::HTTP::Get.new(deliver_path)) if !Rails.env.test? #Never request by accident in test environment.
      end
    end
    logger.info "SMS: get ||| #{deliver_path} ||| #{response.inspect}" # ||| #{response.body if !response.blank?}"
    logger.info response.body if !response.blank?
    response
  end

  def deliver_path
    "/api/sendsms/plain?user=#{ActionSmser.gateway[:username]}&password=#{ActionSmser.gateway[:password]}&sender=#{from_encoded}&SMSText=#{body_encoded_escaped}&GSM=#{to_encoded}"
  end


  attr_reader :body
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
    CGI.escape(Iconv.iconv('ISO-8859-15//TRANSLIT//IGNORE', 'utf-8', message).to_s)
  end

  def to_encoded
    if @to.is_a?(Array)
      # harsh check that receivers are a list of numbers
      @to.collect{|number| number.to_i if number.to_i>1000}.compact.join(",")
    else
      @to.to_s
    end
  end

  def from_encoded
    @from
  end

  def logger
    ActionSmser::Logger
  end


end

