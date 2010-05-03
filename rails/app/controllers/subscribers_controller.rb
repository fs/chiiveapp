class SubscribersController < ApplicationController
  
  before_filter :authorize, :except => [:new, :create]
  before_filter :admin_required, :except => [:new, :create]
  
  def index
    @subscribers = Subscriber.all
    
    respond_to do |format|
      format.html { render :layout => 'static_content' }
    end
  end

  def show
    @subscriber = Subscriber.find(params[:id])
    
    respond_to do |format|
      format.html { render :layout => 'static_content' }
    end
  end

  def new
    @subscriber = Subscriber.new
    
    respond_to do |format|
      format.html { render :layout => 'static_content' }
    end
  end
  
  def create
    @subscriber = Subscriber.new(params[:subscriber])
    respond_to do |format|
      if @subscriber.save
        flash[:notice] = 'Subscriber was successfully created.'
        format.html { render :action => "thank_you", :layout => 'static_content' }
      else
        format.html { render :action => "new", :layout => 'static_content' }
      end
    end
  end
  
  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy

    respond_to do |format|
      format.html { redirect_to(subscribers_url) }
      format.xml  { head :ok }
    end
  end
end
