class MetricsManagerController < ApplicationController
  
  
  # Don't protect from forgery for create and update
  # so that we can post multipart data from mobile devices
  protect_from_forgery :only => [:delete]
  
  def create

    params[:metrics_manager][:user_id] = params[:user_id]
    
    @manager = MetricsManager.new(params[:metrics_manager])
   
    respond_to do |format|
      format.html {render :layout => false } # index.html.erb
      #format.xml  { render :xml => @posts.to_xml(:except => [:address_id]) }
      format.json # index.html.erb
      #format.js 
    end
    
  end
  
  
end