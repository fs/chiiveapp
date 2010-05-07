class UsersController < ApplicationController
  before_filter :authorize, :except => [:new, :create, :edit, :update]
  
  # Don't protect from forgery for create and update
  # so that we can post multipart data from mobile devices
  protect_from_forgery :only => [:delete]
  
  def index
    per_page = params[:per_page] ? params[:per_page] : 30
    paginate_params = {
      :per_page => per_page,
      :page => params[:page]
    }
    
    if params[:q].nil?
      @users = User.find(:all) do
        paginate paginate_params
      end
    else
      like_clause = params[:q]+"%"
      @users = User.find(:all, :conditions => [ "login like ? OR first_name like ? OR last_name like ?", like_clause, like_clause, like_clause ] )
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @posts.to_xml(:except => [:address_id]) }
      format.json { 
        if params[:client_type].blank? and params[:client_version].blank?
          render :action => 'index_deprecated'
        else
          render :action => 'index'
        end
      }
    end
    
  end
  
  def show
    @user = User.find_by_ambiguous_id(params[:id])
    
    respond_to do |format|
      format.html
      format.json { 
        if params[:client_type].blank? and params[:client_version].blank?
          render :action => 'show_deprecated'
        else
          render :action => 'show'
        end
      }
    end
  end
  
  def new
    @user = User.new
    # @user.set_home_location(request.ip)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
      format.json { render :json => @user }
    end
  end
  
  def create
    @user = User.new(params[:user])
    
   # email = TransactionalMailer.create_welcome(@user)
   # render(:text => "<pre>" + email.encoded + "</pre>" )
   # return
    
    respond_to do |format|
      if @user.save
        
        # SEND EMAIL...
        TransactionalMailer.deliver_welcome(@user)
        
        # flash[:notice] = 'Registration successful.'
        format.html { redirect_to user_path(@user) }
        format.xml  { render :xml => @user, :status => :created }
        format.json { 
          if params[:client_type].blank? and params[:client_version].blank?
            render :partial => 'user_deprecated', :locals =>{ :user => @user, :show_private_info => true }
          else
            render :partial => 'user', :object => @user, :locals =>{ :show_social_sets => true, :show_private_info => true }
          end
        }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.json  { render :json => @user.errors } # render the errors with a normal http code # "[[\"Please sign up\", \"for an invite at chiive.com\"]]" }# 
      end
    end
  end
  
  def edit
    @user = User.find_by_ambiguous_id(params[:id])
    @fake_admin = true unless params[:fake_admin].blank?
    
    if @user.id != current_user.id && !current_user.is_admin? && !@fake_admin
      puts "redirect!"
      redirect_to user_path(@user)
    end
  end
  
  def update
    @user = User.find_by_ambiguous_id(params[:id])
    
    # update the user's role if the current user is an admin and user_privileges is set
    update_user_roles(@user, params[:role]) if params[:user_privileges] && current_user.is_admin?
    
    # by default we'll redirect without a save 
    should_redirect = true
    
    # users can update all of their own attributes
    if current_user.id == @user.id
      @user.attributes = params[:user]
      should_redirect = false
      
    # admins may update another user's role
    elsif current_user.is_admin? && params[:user_privileges]
      should_redirect = false
      
    end
    
    respond_to do |format|
      if should_redirect
        puts "redirec to user path without a save!"
        redirect_to user_path(@user)
        
      elsif @user.save
        format.html { redirect_to user_path(@user) }
        format.json {
          if params[:client_type].blank? and params[:client_version].blank?
            render :partial => 'user_deprecated', :locals =>{ :user => @user, :show_private_info => true }
          else
            render :partial => 'user', :object => @user, :locals =>{ :show_private_info => true }
          end
        }
      else
        puts "redirect to user path!"
        format.html { render :action => "edit" }
        format.json  { render :json => @user.errors }
      end
    end
  end
  
  def destroy
    @user = User.find_by_ambiguous_id(params[:id])
    
    if (@user == current_user)
      @user.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to root_path }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  def link_user_accounts
    if current_user && facebook_session
      current_user.link_fb_connect(facebook_session.user) unless current_user.facebook_uid == facebook_session.user.id
    end
    if current_user
      redirect_to user_path(current_user)
    else
      redirect_to root_path
    end
  end
  
  def update_user_roles(user, roles)
    if roles.blank?
      @user.remove_role 'admin'
      @user.remove_role 'moderator'
      return
    end
    
    if params[:role][:admin].blank?
      @user.remove_role 'admin'
    else
      @user.add_role 'admin'
    end

    if params[:role][:moderator].blank?
      @user.remove_role 'moderator'
    else
      @user.add_role 'moderator'
    end
  end
end
