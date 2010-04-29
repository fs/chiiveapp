class ApplicationController < ActionController::Base
  helper :all
  # protect_from_forgery
  ensure_application_is_installed_by_facebook_user
  before_filter :set_current_user
  filter_parameter_logging :fb_sig_friends
  
  attr_accessor :current_user
  helper_method :current_user
  
  def comments
    render :partial => 'layouts/comments.fbml', :locals => { :title => params[:fb_sig_xid] }
  end
  
  protected
  
  def set_current_user
    if facebook_session && facebook_session.secured? && !request_is_facebook_tab?
      self.current_user = User.find_by_facebook_uid(facebook_session.user.to_i)
      # logger.info current_user.inspect
    end
  end  
end
