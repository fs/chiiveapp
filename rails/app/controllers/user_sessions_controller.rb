class UserSessionsController < ApplicationController
  skip_before_filter :set_facebook_session, :only => [:facebook_proxy]
  skip_before_filter :authorize
  
  def new
    @user_session = UserSession.new
  end
  
  def facebook_proxy
    
    puts "rendering facebook proxy"
    @facebook_session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
    @facebook_session.auth_token = params['auth_token']
    secure = @facebook_session.secure_with_session_secret!
    
    puts "secure session created.  parsing the rest of the request"
    
    # if request includes a valid single_access_token (meaning a logged-in user from iPhone or other remote client),
    # link the the user's chiive and facebook accounts
    if (current_user && params['user_credentials'])
      puts "connecting the user's account..."
      current_user.link_fb_connect(@facebook_session.user) unless current_user.facebook_uid == @facebook_session.user.id
      fbuser = current_user
    
    # if the request is meant to create a new account
    elsif (params['fb_request_type'] == 'create')
      puts "creating an account..."
      # make sure there is not already a user with this account
      fbuser = User.find_by_fb_user(@facebook_session.user)
      if fbuser.nil?
        puts "Did not find user. Create instead"
        fbuser = User.create_from_fb_connect(@facebook_session.user)
      else
        puts "Found User: #{fbuser}"
      end
      
    # otherwise, the request is just a login
    else
      puts "logging into an account..."
      # find the user account matching this FB profile
      fbuser = User.find_by_fb_user(@facebook_session.user)
    end
    
    # the user parameters we want to show
    fbuser_params = [ :uuid, :first_name, :last_name, :email, :single_access_token, :facebook_uid, :personal_sets_count ]
    
    # create the user data
    fbuser_data = fbuser.nil? ? "[[\"no user\",\"User not found\"]]" : fbuser.to_json(:only => fbuser_params)
    
    # TODO: Find more elegant solution than cramming JSON into XML response meta data
    render :xml => auth_session_xml(@facebook_session, fbuser_data)
    
  end
  
  def create
    if (!params[:user_session].blank? && params[:user_session][:login].blank? && !params[:user_session][:email].blank?)
      user = User.find_by_email(params[:user_session][:email])
      if (user.nil?)
        params[:user_session][:login] = "n/a" # pass an invalid user id
        params[:user_session][:password] = "n/a" # pass an invalid password
      else
        params[:user_session][:login] = user.login
      end
    end
    @user_session = UserSession.new(params[:user_session])
    
    respond_to do |format|
      if @user_session.save
        @user = @user_session.user
        
        format.html { 
          
          #
          # LIMIT LOGIN TO ADMINS ONLY
          #
          if not @user.is_admin?
            redirect_to '/logout'
            return
          else
            redirect_to '/users'
            return
          end
          #
          #
          
          redirect_to root_path 
          }
        format.xml  { render :xml => @user_session.user, :status => :created }
        format.json {
          if params[:client_type].blank? and params[:client_version].blank?
            render :partial => '/users/user_deprecated', :locals => { :user => @user, :show_social_sets => true, :show_private_info => true }
          else
            render :partial => @user, :locals =>{ :show_social_sets => true, :show_private_info => true, :users_limit => 0 }
          end
        }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_session.errors, :status => :unprocessable_entity }
        format.json  { render :json => @user_session.errors }
      end
    end
  end
    
  def destroy
    @user_session = UserSession.find(params[:id])
    @user_session.destroy unless @user_session.nil?
    flash[:notice] = "You're out!"
    redirect_to root_path
  end
  
protected
  def auth_session_xml(facebook_session, meta_data = nil)
    xm = Builder::XmlMarkup.new(:indent => 2)
    xm << '<auth_getSession_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">'
    xm.session_key facebook_session.session_key
    xm.expires "0"
    xm.uid facebook_session.user.id
    xm.secret facebook_session.secret_from_session
    xm.meta_data meta_data if meta_data
    xm << '</auth_getSession_response>'
    xml = xm.target!
  end
end