module ActionSmser
  class DeliveryReportsController < ApplicationController

    def gateway_commit
      @saved = false

      
      if !ActionSmser.delivery_options[:gateway_commit].blank? &&
          !ActionSmser.delivery_options[:gateway_commit][params['gateway']].blank?

        ActionSmser::Logger.info("Gateway_commit found parser for gateway: #{params['gateway']}")

        msg_id, status = ActionSmser.delivery_options[:gateway_commit][params['gateway']].call(params)

        if msg_id && status
          dr = ActionSmser::DeliveryReport.where(:msg_id => msg_id).first
          if dr
            dr.status = status
            @saved = dr.save
            ActionSmser::Logger.info("Gateway_commit updated item with id: #{msg_id}, updated_status: #{status}")
          else
            ActionSmser::Logger.info("Gateway_commit not found item with id: #{msg_id}, updated_status: #{status}")
          end
        end
      end

      if @saved
        render :text => "Updated info"
      else
        render :text => "Not saved"
      end
    end

    before_filter :admin_access_only, :except => :gateway_commit

    def index
    end

    def admin_access_only
      if !ActionSmser.delivery_options[:admin_access].blank? && ActionSmser.delivery_options[:admin_access].call(self)
        return true
      else
        render :text => "Forbidden, only for admins", :status => 403
        return false
      end
    end

  end
end
