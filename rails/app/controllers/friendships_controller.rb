class FriendshipsController < ApplicationController
  
  protect_from_forgery :except => [:create, :destroy, :index, :find_by_email]
  
  def index
    if (params[:user_id].to_s == params[:user_id].to_i.to_s)
      @user = User.find(params[:user_id])
    else
      @user = User.find_by_uuid(params[:user_id])
    end
    
    # Set up conditions for searching for only non-friends
    joins = nil
    conditions = ''
    unless params[:nonfriends].blank? or !current_user
      joins = "left join friendships on (friendships.user_id = #{current_user.id} AND friendships.friend_id = users.id)"
      conditions = 'friendships.id is NULL AND '
    end
    
    if (not params[:facebook].blank?)
      # make sure we have a session
      if (@facebook_session.nil?)
        @facebook_session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
      end
      
      # create the FB User object
      @fb_user = Facebooker::User.new(current_user.facebook_uid, @facebook_session)
      # grab the array of facbook UIDs for the user's friends
      friend_ids = @fb_user.friend_ids
      conditions << 'users.facebook_uid IN (?)'
      @users = User.find( :all, :joins => joins, :conditions => [ conditions, friend_ids ])
    
    elsif (not params[:email].blank?)
      emails = params[:email].split(',')
      conditions << 'users.email IN (?)'
      @users = User.find( :all, :joins => joins, :conditions => [ conditions, emails ])
    
    # only display people who have accepted or created a friend request
    else
        @users = @user.friends_for_me
    
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @users.to_xml }
      format.json { 
        if params[:client_type].blank? and params[:client_version].blank?
          render :action => 'index_deprecated'
        else
          render :action => 'index'
        end
      }
    end
    
  end
  
  def find_by_email
    if (params[:user_id].to_s == params[:user_id].to_i.to_s)
      @user = User.find(params[:user_id])
    else
      @user = User.find_by_uuid(params[:user_id])
    end
    
    # Set up conditions for searching for only non-friends
    joins = nil
    conditions = ''
    unless params[:nonfriends].blank? or !current_user
      joins = "left join friendships on (friendships.user_id = #{current_user.id} AND friendships.friend_id = users.id)"
      conditions = 'friendships.id is NULL AND '
    end
    
    emails = params[:email].split(',')
    conditions << 'users.email IN (?)'
    @users = User.find( :all, :joins => joins, :conditions => [ conditions, emails ])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @users.to_xml }
      format.json { render :action => 'index' }
    end
  end
  
  def create
    if (params[:friend_id].to_s == params[:friend_id].to_i.to_s)
      @user = User.find(params[:friend_id])
    else
      @user = User.find_by_uuid(params[:friend_id])
    end
    
    # check if the friendship is already set up
    if (current_user.is_friends_with?(@user) || current_user.id == @user.id)
      respond_to do |format|
        puts "Already friends!"
        flash[:notice] = "Already friends!."
        format.html { redirect_to current_user }
         format.json { 
            if params[:client_type].blank? and params[:client_version].blank?
              render :partial => "users/user_deprecated", :locals => { :user => @user }
            else
              render :partial => "users/user", :locals => { :user => @user }
            end
          }
      end
    else
      @friendship = current_user.friendships.build(:friend_id => @user.id)
      respond_to do |format|
        if @friendship.save
          puts "Added Friendship!"
          flash[:notice] = "Added friend."
          format.html { redirect_to current_user }
          format.json { 
            if params[:client_type].blank? and params[:client_version].blank?
              render :partial => "users/user_deprecated", :locals => { :user => @user }
            else
              render :partial => "users/user", :locals => { :user => @user }
            end
          }
        else
          puts "Error Creating Friendship!"
          flash[:error] = "Unable to add friend."
          format.html { redirect_to current_user }
          format.json { render :json => @friendship.errors }
        end
      end
    end
  end
  
  def destroy
    friendship = Friendship.find_by_id(params[:id])
    
    if (!friendship.nil? && (friendship.friend_id == current_user.id || friendship.user_id == current_user.id))
      
      # find the reverse friendship if it exiests
      reverse_friendship = Friendship.find(:first) do
        friend_id == friendship.user_id
        user_id == friendship.friend_id
      end
      
      # destroy all reverse friendships
      reverse_friendship.destroy unless reverse_friendship.nil?
      
      # destroy the requested friendship to be destroyed
      friendship.destroy
      flash[:notice] = "Removed friendship."
    end

    respond_to do |format|
      format.html { redirect_to current_user }
      format.xml  { head :ok }
      format.json { head :ok }
      format.js { head :ok }
    end
  end
  
end