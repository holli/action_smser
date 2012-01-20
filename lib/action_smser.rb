require "action_smser/engine"
require "action_smser/base"

Dir[File.dirname(__FILE__) + '/action_smser/delivery_methods/*.rb'].each do |file|
  require file
end

module ActionSmser

  mattr_accessor :delivery_options
  self.delivery_options= {:delivery_method => :test_array, :save_delivery_reports => false}
  self.delivery_options[:gateway_commit] = {}

  class Logger
    def self.info(str)
      Rails.logger.info("ActionSmser: #{str}")
    end
    def self.warn(str)
      Rails.logger.warn("ActionSmser: #{str}")
    end
  end

end


