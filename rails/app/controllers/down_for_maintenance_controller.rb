class DownForMaintenanceController < ApplicationController
  
  before_filter :authorize, :except => [:index]
  before_filter :admin_required, :except => [:index]
  

  def index
    respond_to do |format|
      format.html { render :action => "index", :layout => "invitation_requests" } # will render: index.html.erb
      format.json # will render: index.json.erb
    end
  end

  # def new
  #   respond_to do |format|
  #     format.html # new.html.erb
  #   end
  # end

end
