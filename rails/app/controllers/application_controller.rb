# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # enable facebook connect throughout the site
  ensure_application_is_installed_by_facebook_user :if => :request_comes_from_facebook?
  before_filter :set_facebook_user, :if => :request_comes_from_facebook?
  before_filter :set_facebook_session, :unless => :request_comes_from_facebook?
  helper_method :facebook_session
  
  
  # Redirect to ROOt unless the user is logged in
  # Use: 
  #     skip_before_filter :authorize
  # to skip this restriction (ie. used in users_sessions_controller.rb to allow login/logout)
  #
  # password protect the site
  before_filter :authorize
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  # scrub facebook friend signatures to avoid violating FB terms of use
  filter_parameter_logging :fb_sig_friends
  
  helper_method :current_user_session, :current_user
  
  def admin_required
    unless current_user && current_user.is_admin?
      flash[:error] = "Sorry, you don't have access to that."
      redirect_to root_url and return false
    end
  end
  
protected

  def authorize
    redirect_to root_url unless current_user
  end
  
  def current_user_session
    # puts "current user session: #{@current_user_session}"
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    # puts "current user: #{@current_user}"
    # return @current_user if defined?(@current_user)
    @current_user ||= current_user_session && current_user_session.record
  end
  
  def set_facebook_user
    @current_user = User.find_or_create_facebook_user(facebook_session)
  end
  
  def facebook_redirect
    redirect_to social_sets_url
  end
  
end