module ActionSmser
  class DeliveryReport < ActiveRecord::Base

    def self.build_from_sms(sms, to, msg_id)
      @delivery_report = self.new

      [:from, :body, :sms_type].each do |var|
        @delivery_report.send("#{var}=", sms.send(var))
      end
      @delivery_report.to = to
      @delivery_report.msg_id = msg_id
      @delivery_report.status = "LOCAL_SENT"
      @delivery_report.gateway = sms.delivery_options[:delivery_method].to_s
      @delivery_report
    end

    def self.create_from_sms(sms, to, sms_id)
      @delivery_report = self.build_from_sms(sms, to, sms_id)
      @delivery_report.save
      @delivery_report
    end

    def status=(stat, skip_log = false)
      self[:status] = stat
      self.status_updated_at = Time.now
      add_log("#{Time.now.to_s(:db)}: #{stat}") unless skip_log
    end

    def add_log(str)
      self.log = "" if self.log.nil?
      self.log += "#{str}\n"
    end

    # Copy this delivery_report information to a new sms object
    def to_sms
      sms_new = ActionSmser::Base.new()
      [:sms_type, :to, :from, :body, :sms_type].each do |var|
        sms_new.send("#{var}=", self.send(var))
      end
      sms_new
    end

    def re_deliver(gateway = :default)
      self.update_attribute(:re_delivered, true)
      
      sms_new = self.to_sms
      sms_new.sms_type = "#{sms_new.sms_type}_resent"
      sms_new.resent_of_delivery_report_id = self.id

      unless gateway == :default
        sms_new.delivery_options[:delivery_method] = gateway
      end

      [sms_new, sms_new.deliver]
    end

  end
end
