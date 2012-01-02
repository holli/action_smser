module ActionSmser
  class DeliveryReportsController < ApplicationController

    def 


    # GET /delivery_reports
    # GET /delivery_reports.json
    def index
      @delivery_reports = DeliveryReport.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @delivery_reports }
      end
    end
  
    # GET /delivery_reports/1
    # GET /delivery_reports/1.json
    def show
      @delivery_report = DeliveryReport.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @delivery_report }
      end
    end
  
    # GET /delivery_reports/new
    # GET /delivery_reports/new.json
    def new
      @delivery_report = DeliveryReport.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @delivery_report }
      end
    end
  
    # GET /delivery_reports/1/edit
    def edit
      @delivery_report = DeliveryReport.find(params[:id])
    end
  
    # POST /delivery_reports
    # POST /delivery_reports.json
    def create
      @delivery_report = DeliveryReport.new(params[:delivery_report])
  
      respond_to do |format|
        if @delivery_report.save
          format.html { redirect_to @delivery_report, :notice => 'Delivery report was successfully created.' }
          format.json { render :json => @delivery_report, :status => :created, :location => @delivery_report }
        else
          format.html { render :action => "new" }
          format.json { render :json => @delivery_report.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # PUT /delivery_reports/1
    # PUT /delivery_reports/1.json
    def update
      @delivery_report = DeliveryReport.find(params[:id])
  
      respond_to do |format|
        if @delivery_report.update_attributes(params[:delivery_report])
          format.html { redirect_to @delivery_report, :notice => 'Delivery report was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @delivery_report.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /delivery_reports/1
    # DELETE /delivery_reports/1.json
    def destroy
      @delivery_report = DeliveryReport.find(params[:id])
      @delivery_report.destroy
  
      respond_to do |format|
        format.html { redirect_to delivery_reports_url }
        format.json { head :ok }
      end
    end
  end
end
