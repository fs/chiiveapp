class PostsController < ApplicationController
  include GeoKit::Geocoders
  
  # Don't protect from forgery for create and update
  # so that we can post multipart data from mobile devices
  protect_from_forgery :only => [:delete]
  
  def index
    per_page = params[:per_page] ? params[:per_page] : 30
    paginate_params = {
      :per_page => per_page,
      :page => params[:page]
    }
    
    if (params[:user_id].to_s == params[:user_id].to_i.to_s)
      @user = User.find_by_id(params[:user_id])
    else
      @user = User.find_by_uuid(params[:user_id])
    end   
    
    if not params[:personal_set_id].nil?
      puts "personal set id checked!"
      @personal_set = PersonalSet.find(params[:personal_set_id])
      @posts = @personal_set.posts
    
    elsif not params[:social_set_id].nil?
      puts "social set id checked!"
      if (params[:social_set_id].to_s == params[:social_set_id].to_i.to_s)
        @social_set = SocialSet.find(params[:social_set_id])
      else
        @social_set = SocialSet.find_by_uuid(params[:social_set_id])
      end
      
      @posts = @social_set.posts
    end
    
    unless defined?(@posts)
      @posts = Post.find(:all) do
        user_id == params[:user_id]
        paginate paginate_params
      end
    end
    
    respond_to do |format|
      format.html # index.html.erb
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
    if (params[:id].to_s == params[:id].to_i.to_s)
      @post = Post.find_by_id(params[:id])
    else
      @post = Post.find_by_uuid(params[:id])
    end   
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post.to_xml(:except => [:address_id]) }
      format.json { 
        if params[:client_type].blank? and params[:client_version].blank?
          render :action => 'show_deprecated'
        else
          render :action => 'show'
        end
      }
      format.js 
    end
  end
  
  def new
    #@personal_set_id = params[:personal_set_id] ? params[:personal_set_id] : ""
    
    @post = Post.new
    @post.user = current_user
    
    # find the correct personal set for the user
    @post.personal_set = PersonalSet.find(:first) do
      social_set_id == params[:social_set_id]
      user_id == current_user.id
    end
    
    if @post.personal_set.nil?
      @post.build_personal_set
      
      if (params[:social_set_id].to_s == params[:social_set_id].to_i.to_s)
        @post.personal_set.social_set = SocialSet.find(params[:social_set_id])
      else
        @post.personal_set.social_set = SocialSet.find_by_uuid(params[:social_set_id])
      end
    end
    
    puts "post user: #{@post.user}"
    # ip = request.remote_ip
    # ip = '76.195.14.73' if ip == '127.0.0.1'
    # location = IpGeocoder.geocode(ip)
    
    # if location.success
    #   @post.latitude = location.lat
    #   @post.longitude = location.lng
    # else
      @post.latitude = 37.789873
      @post.longitude = -122.404897
    # end
    puts "set the lat and long!"
  end
  
  def create
    
    # If this is a repeat upload
    if params[:post]
      if params[:post][:uuid]
        @post = Post.find(:first) do
          user_id == current_user.id
          uuid == params[:post][:uuid]
        end
      end
    end
    
    # if this is a new post
    if @post.nil?
      @post = Post.new(params[:post])
    else
      @post.attributes = params[:post]
    end
    
    @post.user = current_user
    
    if (params[:social_set_id].to_s == params[:social_set_id].to_i.to_s)
      social_set = SocialSet.find_by_id(params[:social_set_id])
    else
      social_set = SocialSet.find_by_uuid(params[:social_set_id])
    end
    
    assign_post_social_set(@post, social_set)
    
    @post.time_at = Time.new if @post.time_at.blank?
    
    respond_to do |format|
      if @post.save
        # flash[:notice] = 'Successfully created post.'
        format.html { redirect_to user_social_set_path(@post.user, @post.social_set) }
        format.xml  { render :xml => @post.to_xml(:except => [:address_id]), :status => :created }
        format.json { 
          if params[:client_type].blank? and params[:client_version].blank?
            render :action => 'show_deprecated'
          else
            render :action => 'show'
          end
        }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json { render :json => @post.errors }
      end
    end
  end
  
  def edit
    @post = Post.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js{
        options_for_edit_in_place(@post, params)
      }
    end
  end
  
  def update
    if (params[:id].to_s == params[:id].to_i.to_s)
      @post = Post.find_by_id(params[:id])
    else
      @post = Post.find_by_uuid(params[:id])
    end   
    
    respond_to do |format|
      if @post.user == current_user && @post.update_attributes(params[:post])
        # flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to user_social_sets_path(@post.user) }
        format.xml  { head :ok }
        format.json { 
          if params[:client_type].blank? and params[:client_version].blank?
            render :action => 'show_deprecated'
          else
            render :action => 'show'
          end
        }
      else
        format.html { render :action => "edit" }
        format.js
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json  { render :json => @post.errors }
      end
    end
  end
  
  def destroy
    if (params[:id].to_s == params[:id].to_i.to_s)
      @post = Post.find_by_id(params[:id])
    else
      @post = Post.find_by_uuid(params[:id])
    end
    
    respond_to do |format|
      unless @post.nil? || @post.user != current_user
        the_social_set = @post.social_set
        the_user = the_social_set.default_user
        @post.destroy
        
        puts "Destroyed that post! redirecting to #{user_social_set_path(the_user, the_social_set)} "
        flash[:notice] = "Successfully destroyed post."
        
        format.html { redirect_to user_social_set_path(the_user, the_social_set) }
        format.xml { head :ok }
        format.json { head :ok }
        format.js
      else
        format.html { redirect_to user_social_sets_path(current_user) }
        format.xml { head :ok }
        format.json { head :ok }
        format.js
      end
    end
  end

private
  def assign_post_social_set(post, social_set)
    return if social_set.nil?
    
    # find the post's owner's personal set for the new social set
    if (post.social_set.nil? or post.social_set != social_set)
      post.personal_set = social_set.personal_sets.find_by_user_id(post.user.id)
      # post.personal_set = PersonalSet.find(:first, 
      #                       :conditions => ["user_id = :user_id and social_set_id = :social_set_id", 
      #                         {:user_id => post.user_id, :social_set_id => social_set.id}])
      
      # if the post's owner did not yet have a personal set, create one
      if post.personal_set.nil?
        post.build_personal_set
        post.personal_set.social_set = social_set
      end
    end
  end
  
  def options_for_edit_in_place(object, request_params)
    attribute_metadata = object.class.content_columns.select{|v| v.name == request_params[:attribute]}.first
    if request_params[:attribute] && attribute_metadata
      @options = {
        :token => form_authenticity_token,
        :url => user_post_path(params[:user_id], params[:id]), #'/posts/1', # url_for(object),
        :model => object.class.to_s.underscore,
        :attr => request_params[:attribute],
        :type => attribute_metadata.type,
        :id => request_params[:id]
      }
      @options.update(:data => object[request_params[:attribute]]) if request_params[:read_data]
    else
      render :nothing => true, :status => :not_found
    end
  end


end
