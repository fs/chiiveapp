class CommentsController < ApplicationController
  
  # Don't protect from forgery for create and update
  # so that we can post data from mobile devices
  protect_from_forgery :only => [:delete]
  
  def index
    
    if (params[:post_id] && params[:user_id].to_s == params[:user_id].to_i.to_s)
      @post = Post.find(params[:post_id]) 
      @comments = @post.comments
    elsif (params[:post_id])
      @post = Post.find_by_uuid(params[:post_id]) 
      @comments = @post.comments
    end
    
    if (params[:personal_set_id])
      @personal_set = PersonalSet.find(params[:personal_set_id])
      @comments = @personal_set.comments
    end
    
    respond_to do |format|
      if (defined?(@post)) # POST
        format.html { redirect_to user_social_set_post_path(User.find(params[:user_id]), @post.social_set, @post) }
        format.json { 
          if params[:client_type].blank? and params[:client_version].blank?
            render :action => 'index_deprecated'
          else
            render :action => 'index'
          end
        }

      else # GROUP
        format.html { redirect_to user_social_set_path(User.find(params[:user_id]), @personal_set.social_set) }
        format.json
        
      end
      
    end
  end

  def show
    if (params[:id].to_s == params[:id].to_i.to_s)
      @comment = Comment.find(params[:id])
    else
      @comment = Comment.find_by_uuid(params[:id])
    end
    
    respond_to do |format|
      format.html # show.html.erb
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
    @comment = Comment.new()

    respond_to do |format|
      format.html
      format.json
    end
  end

  def edit
    #@user = User.find(params[:user_id])
    @comment = Comment.find(params[:id])

    if @comment.user == current_user
    # ALLOW EDIT
      respond_to do |format|
        # TODO: fix. Can we generalize and abstract 'post' and 'personal_set' ?
        format.html
        format.json
      end
    else
    # DON't ALLOW EDIT
      redirect_to params[:redirect_url]
    end
  end

  def create
    # replace a commentable UUID with a commentable ID
    if (params[:comment][:commentable_id].to_s != params[:comment][:commentable_id].to_i.to_s)
      if (params[:comment][:commentable_type] == "Post")
        commentable = Post.find_by_uuid(params[:comment][:commentable_id])
        params[:comment][:commentable_id] = commentable.id
      elsif (params[:comment][:commentable_type] == "SocialSet")
        commentable = SocialSet.find_by_uuid(params[:comment][:commentable_id])
        params[:comment][:commentable_id] = commentable.id
      end
    end
    
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    @comment.title = @comment.body if @comment.title.blank?
    
    respond_to do |format|
      if @comment.save
        format.html { redirect_to params[:redirect_url] }
        format.json { render :action => 'show' }
      else
        format.html { redirect_to params[:redirect_url] }
        format.json  { render :json => @comment.errors }
      end
    end
  end

  def update
    if (params[:id].to_s == params[:id].to_i.to_s)
      @comment = Comment.find(params[:id])
    else
      @comment = Comment.find_by_uuid(params[:id])
    end
    
    respond_to do |format|
      if @comment.user == current_user && @comment.update_attributes(params[:comment])
        
        # TODO: fix. Can we generalize and abstract 'post' and 'personal_set' ?
        @commentable = @comment.commentable
        if (@comment.commentable_type == "Post") # POST
          @post = @commentable
          flash[:notice] = 'Comment was successfully updated.'
          format.html { redirect_to user_social_set_post_path(@commentable.user, @commentable.personal_set.social_set, @commentable) }
          format.json { 
            if params[:client_type].blank? and params[:client_version].blank?
              render :action => 'show_deprecated'
            else
              render :action => 'show'
            end
          }
        else # GROUP
          @personal_set = @commentable
          flash[:notice] = 'Comment was successfully updated.'
          format.html { redirect_to user_social_set_path(@commentable.user, @commentable.social_set) }
          format.json
        end
        
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @comment.errors }
      end
    end
  end

  def destroy
    if (params[:id].to_s == params[:id].to_i.to_s)
      @comment = Comment.find(params[:id])
    else
      @comment = Comment.find_by_uuid(params[:id])
    end
    
    if (comment.user == current_user)
      @comment.destroy
    end
    
    respond_to do |format|
       format.html { redirect_to params[:redirect_url] }
       format.json  { head :ok }
    end
  end
end
