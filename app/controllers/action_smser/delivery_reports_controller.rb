module ActionSmser
  class DeliveryReportsController < ApplicationController

    def gateway_commit
      @saved = false

      if params["DeliveryReport"] && params["DeliveryReport"]["message"]
        info = params["DeliveryReport"]["message"]
        msg_id = info["id"]
        status = info["status"]

        dr = ActionSmser::DeliveryReport.where(:msg_id => msg_id).first
        if dr
          dr.status = status
          @saved = dr.save
          ActionSmser::Logger.info("Gateway_commit updated item with id: #{msg_id}, updated_status: #{status}")
        else
          ActionSmser::Logger.info("Gateway_commit not found item with id: #{msg_id}, updated_status: #{status}")
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
      render :text => "Forbidden, only for admins", :status => 403
      return false
    end

  end
end
