require "action_smser/engine"
require "action_smser/base"

module ActionSmser
  @gateway = {}
  def self.gateway
    @gateway
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
