class InvitationRequestsController < ApplicationController
  
  #caches_page :new 
  #caches_action :new
  
  # lets us use .iphone for VIEWs
  #has_mobile_fu
  
  before_filter :authorize, :except => [:new, :create]
  before_filter :admin_required, :except => [:new, :create]
  
  def index
    @invitation_requests = InvitationRequest.all
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @invitation_request = InvitationRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @invitation_request = InvitationRequest.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @invitation_request = InvitationRequest.find(params[:id])
  end

  def create
    @invitation_request = InvitationRequest.new(params[:invitation_request])
    
    # email = InvitationMailer.create_thankyou(@invitation_request)
    # render(:text => "<pre>" + email.encoded + "</pre>" )
    # return
    
    respond_to do |format|
      if @invitation_request.save
        InvitationMailer.deliver_thankyou(@invitation_request)
        format.html { redirect_to(@invitation_request) }
        format.js
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @invitation_request = InvitationRequest.find(params[:id])

    respond_to do |format|
      if @invitation_request.update_attributes(params[:invitation_request])
        flash[:notice] = 'InvitationRequest was successfully updated.'
        format.html { redirect_to(@invitation_request) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @invitation_request = InvitationRequest.find(params[:id])
    @invitation_request.destroy

    respond_to do |format|
      format.html { redirect_to(invitation_requests_url) }
    end
  end
end
