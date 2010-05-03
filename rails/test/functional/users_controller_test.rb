require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @first_user = Factory(:user)
  end

  context "before login" do
    context "the show action" do
      setup do
        get :show, :id => User.first
      end

      should_respond_with :success
      should_render_template :show
     end

    context "the new action" do
      setup do
        get :new
      end
      
      should_render_template :new
    end

    context "the create action with bad password" do
      setup do
       post :create, :user => Factory.attributes_for(:user, :password_confirmation  => 'bad_password')
      end
      
      should_render_template :new
    end
    
    context "the create action with no login" do
      setup do
        post :create, :user => Factory.attributes_for(:user, :login  => '')
      end
      
      should_render_template :new
    end

    context "the create action" do
      setup do
        post :create, :user => Factory.attributes_for(:user)
        # assert_nil assigns(:user).errors
      end
      
      should_redirect_to("the posts page") { posts_path }
    end

    context "the edit action" do
      setup do
        get :edit, :id => User.first
      end
    
      should_redirect_to("the login page") { login_path }
    end
    
    context "the update action" do
      setup do
        put :update, :user => {:login => "new_login"}, :id => User.first
      end
      
      should_redirect_to("the login page") { login_path }
    end
    
    context "the delete action" do
      setup do
        delete :destroy, :id => User.first
      end
      
      should_redirect_to("the login page") { login_path }
    end
    
  end

  context "after login" do
    setup do
      activate_authlogic
      Factory(:user) # creating a user automatically instantiates a session
    end
  
    context "the edit action" do
      setup do
        get :edit, :id => User.first
      end
  
      should_render_template :edit
    end
  
    context "the update action" do
      setup do
        put :update, :user => {:login => "new_login"}, :id => User.first
      end
  
      should_redirect_to("the show page") { user_path assigns(:user) }
    end
  
    context "the update action with short password" do
      setup do
        put :update, :user => {:password => "f00", :password_confirmation => "f00"}, :id => User.first
      end
  
      should_render_template :edit
    end
  
    context "the update action with unconfirmed password" do
      setup do
        put :update, :user => {:password => "f00bazar"}, :id => User.first
      end
  
      should_render_template :edit
    end
  
    context "the delete action" do
      setup do
        delete :destroy, :id => User.first
      end
  
      should_redirect_to("the posts page") { posts_path }
    end
  end
end
