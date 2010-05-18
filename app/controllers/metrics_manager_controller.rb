class MetricsManagerController < ApplicationController
  
  
  # Don't protect from forgery for create and update
  # so that we can post multipart data from mobile devices
  protect_from_forgery :only => [:delete]
  
  def create

    params[:metrics_manager][:user_id] = current_user.id
    
    @manager = MetricsManager.new(params[:metrics_manager])
   
    respond_to do |format|
      format.html { render :layout => false }
      format.json
    end
  end  
end