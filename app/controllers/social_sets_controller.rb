class SocialSetsController < ApplicationController
  include GeoKit::Geocoders
  
  # Don't protect from forgery for create and update
  # so that we can post multipart data from mobile devices
  protect_from_forgery :only => [:delete]

  #####################################################
  # INDEX
  #####################################################
  def index
    per_page = params[:per_page] ? params[:per_page] : 30
    paginate_params = {
      :per_page => per_page,
      :page => params[:page]
    }
    
    # @updated_at = Time.new # 10.days.ago # 
    @user = params[:user_id].nil? ? nil : User.find_by_ambiguous_id(params[:user_id])
      
    # Null user
    if @user.nil?
      @social_sets = SocialSet.find(:all) do
        paginate paginate_params
      end
    
    # current user
    elsif @user.id == current_user.id
      #@social_sets = current_user.social_sets.find(:all, :include => [{:personal_sets, {:posts => :comments}]) do
      @social_sets = current_user.social_sets.find(:all) do
        paginate paginate_params
      end
    
    # Friend of current user
    elsif @user.is_friends_with?(current_user)
      @social_sets = @user.social_sets.find(:all) do
        paginate paginate_params
      end
      
      
    # Sets of another user, not friend w/ 'current_user'  
    else
      
      # Public Sets
      sql = "SELECT social_sets.* FROM social_sets "
      sql << "INNER JOIN personal_sets AS public_sets ON "
        sql << "public_sets.public = 1 AND public_sets.user_id = #{@user.id} "
        sql << "AND public_sets.social_set_id = social_sets.id "
      
      # Shared Private Sets
      sql << "UNION SELECT social_sets.* FROM social_sets "
      sql << "INNER JOIN personal_sets AS private_sets ON "
        sql << "private_sets.public = 0 AND private_sets.user_id = #{@user.id} AND social_sets.id = private_sets.social_set_id "
      sql << "INNER JOIN personal_sets AS user_sets ON "
      sql << "private_sets.social_set_id = user_sets.social_set_id AND user_sets.user_id = #{current_user.id} "
      
      # Sets with shared friends
      sql << "UNION SELECT social_sets.* FROM social_sets "
      sql << "INNER JOIN personal_sets AS private_sets ON "
        sql << "private_sets.public = 0 AND private_sets.user_id = #{@user.id} AND social_sets.id = private_sets.social_set_id "
      
      sql << "INNER JOIN personal_sets AS friends_sets ON "
        sql << "private_sets.social_set_id = friends_sets.social_set_id AND "
        sql << "(NOT (friends_sets.user_id = #{current_user.id} OR friends_sets.user_id = #{@user.id})) "
      
      sql << "INNER JOIN friendships ON "
          sql << "friendships.user_id = friends_sets.user_id AND friendships.friend_id = #{current_user.id} "
      
      @social_sets = SocialSet.paginate_by_sql(sql, paginate_params)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.fbml
      format.xml { render :xml => @social_sets.to_xml }
      format.json { 
        if params[:client_type].blank? and params[:client_version].blank?
          render :action => 'index_deprecated'
        else
          render :action => 'index'
        end
      }
    end
  end
  
  #####################################################
  # SHOW
  #####################################################
  def show
    @social_set = SocialSet.find_by_ambiguous_id(params[:id])
    @posts = @social_set.posts.paginate(:page => params[:posts_page], :per_page => 48)
    @personal_sets = @social_set.personal_sets.paginate(:page => params[:users_page], :per_page => 10)
    
    respond_to do |format|
      format.html
      format.fbml
      format.fbjs
      format.xml { render :xml => @social_sets.to_xml }
      format.json { 
        if params[:client_type].blank? and params[:client_version].blank?
          render :action => 'show_deprecated'
        else
          render :action => 'show'
        end
      }
    end
  end
  
 
  #####################################################
  # EDIT
  #####################################################
  def edit
    @social_set = SocialSet.find(params[:id])
    
    respond_to do |format|
      # format.html
      format.js{
        options_for_edit_in_place(@social_set, params)
      }
    end
  end
  
  def update 
    social_set_data = params[:social_set].blank? ? params[:event] : params[:social_set]
    @social_set = SocialSet.find_by_ambiguous_id(params[:id])

    respond_to do |format|
     if current_user == @social_set.default_user && @social_set.default_personal_set.update_attributes(social_set_data[:personal_sets_attributes]['0'])
       format.html { 
         flash[:notice] = 'social_set was successfully updated.'
         redirect_to(@social_set)
       }
       format.json { 
         if params[:client_type].blank? and params[:client_version].blank?
             render :action => 'show_deprecated'
           else
             render :action => 'show'
         end
       }
     else
       format.html { render :action => "edit" }
       format.json { 
         if params[:client_type].blank? and params[:client_version].blank?
           render :show_deprecated
         else
           render :show
         end
       }
     end
    end
  end
  
  #####################################################
  # NEW
  #####################################################
  def new
    @social_set = SocialSet.new()
    @social_set.personal_sets.build
    @social_set.personal_sets.first.posts.build
  end
  
  #####################################################
  # CREATE
  #####################################################
  def create
    social_set_data = params[:social_set].blank? ? params[:event] : params[:social_set]
    
    unless social_set_data[:id].nil?
      @social_set = SocialSet.find_by_ambiguous_id(social_set_data[:id])
    end
    
    if @social_set.nil? && !social_set_data[:uuid].blank?
      @social_set = SocialSet.find_by_uuid(social_set_data[:uuid])
    end
    
    if @social_set.nil?
      
      @social_set = SocialSet.new(social_set_data)
      
      # Assign the metrics from the personal set
      @social_set.latitude = @social_set.default_personal_set.latitude
      @social_set.longitude = @social_set.default_personal_set.longitude
      @social_set.time_at = @social_set.default_personal_set.time_at
    
      # Assign the current user
      @social_set.default_personal_set.user = current_user
      @social_set.default_personal_set.posts.each do |post|
        post.user = current_user
      end
      
    else
      # Find the personal_set for the current user
      personal_set = current_user.personal_sets.find(:first, :conditions => ['social_set_id = ?', @social_set.id])
      
      # if there is no personal_set exists for this user, then check him in!
      if personal_set.nil? 
        # Checkin in (create a new personal_set)
        social_set_data[:personal_sets_attributes][0][:user_id] = current_user.id
        social_set_data[:personal_sets_attributes][0][:title] = @social_set.title

        @social_set.attributes = social_set_data
        
      else
        personal_set.update_attributes(social_set_data[:personal_sets_attributes]['0'])
        
      end
      
    end

    # make sure the personal set has a title of some kind
    if @social_set.default_personal_set.title.blank?
      @social_set.default_personal_set.title = "Untitled"
    end
    
    # SAVE
    respond_to do |format|
      if @social_set.save
        format.html { redirect_to user_social_set_path(current_user, @social_set) }
        format.xml  { render :xml => @social_set.to_xml(:except => [:address_id]), :status => :created }
        format.json { 
          if params[:client_type].blank? and params[:client_version].blank?
            render :action => 'show_deprecated'
          else
            render :action => 'show'
          end
        }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @social_set.errors, :status => :unprocessable_entity }
        format.json { render :json => @social_set.errors }
      end
    end
  end


  def destroy
    
    # Lets try to get the social_set in question
    if !params[:id].nil?
      @social_set = SocialSet.find_by_ambiguous_id(params[:id])
    end
    
    respond_to do |format|
      if @social_set.nil?
        format.html { redirect_to user_social_sets_path(current_user) }
        format.json { head :ok }
      else
        
        # Check out
        personal_set = current_user.personal_sets.find(:first, :conditions => ['social_set_id = ?', @social_set.id])
        
        unless (personal_set.nil?) # and personal_set.posts.size == 0)
          if (@social_set.personal_sets.size > 1)
            personal_set.destroy
          else
            @social_set.destroy
            @social_set = nil
          end
        end
        format.html { redirect_to(@social_set.nil?) ? 
                        user_social_sets_path(current_user) : 
                        user_social_set_path(@social_set.default_personal_set.user, @social_set)
                    }
        format.json { head :ok }
      end
    end
    
  end
end
