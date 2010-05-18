# SEE: http://www.binarylogic.com/2008/11/16/tutorial-reset-passwords-with-authlogic/

class PasswordResetsController < ApplicationController
  
  skip_before_filter :authorize
  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
  before_filter :require_no_user
  
  #
  # CREATION
  #
  
  def new
    render
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
      "Please check your email."
      redirect_to root_url
    else
      flash[:notice] = "No user was found with that email address"
      render :action => :new
    end
  end


  #
  # EDIT
  #

  def edit
    render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated"
      
      if not @user.is_admin
        redirect_to logout
      else
        redirect_to root_url
      end
      
    else
      render :action => :edit
    end
  end

  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. " +
                        "If you are having issues try copying and pasting the URL " +
                        "from your email into your browser or restarting the " +
                        "reset password process."
      redirect_to root_url
    end
  end
  
  #
  # Make sure the user is not logged
  #
  
  def require_no_user
    if current_user
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end
  
  
end