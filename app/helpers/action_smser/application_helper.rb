module ActionSmser
  module ApplicationHelper

    def dr_summary_url(new_params)
      delivery_reports_url({:time_span => params[:time_span], :gateway => params[:gateway], :redeliveries => params[:redeliveries]}.merge(new_params))
    end

  end
end
