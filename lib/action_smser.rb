require "action_smser/engine"
require "action_smser/base"

require "action_smser/delivery_methods/test_array"
require "action_smser/delivery_methods/simple_http"
require "action_smser/delivery_methods/nexmo"
require "action_smser/delivery_methods/delayed_job"
require "action_smser/delivery_methods/smstrade"

module ActionSmser

  mattr_accessor :delivery_options
  self.delivery_options= {:delivery_method => :test_array, :save_delivery_reports => false, :default_ttl => (24*60*60) }
  self.delivery_options[:gateway_commit] = {}
  self.delivery_options[:gateway_commit_observers] = []

  def self.gateway_commit_observer_add(observer_class)
    self.delivery_options[:gateway_commit_observers].push(observer_class)
  end

  class Logger
    def self.info(str)
      Rails.logger.info("ActionSmser: #{str}")
    end
    def self.warn(str)
      Rails.logger.warn("ActionSmser: #{str}")
    end
    def self.error(str)
      Rails.logger.error("ActionSmser: #{str}")
    end
  end

end


