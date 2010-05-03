require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  
  def setup
    @post = Factory(:post)
  end
  
  context "before login" do
    context "the index action" do
      setup do
        get :index
      end
    
      should_respond_with :success
      should_render_template :index
    end
  
    context "the show action" do
      setup do
        get :show, :id => Post.first
      end
    
      should_respond_with :success
      should_render_template :show
     end
   
    context "the new action" do
      setup do
        get :new
      end
      # should_render_template :new
      should_redirect_to("the login page") { login_path }
    end

    context "the create action" do
      setup do
        post :create, :post => Factory.build(:post).attributes
      end
    
      should_redirect_to("the login page") { login_path }
    end
  
    context "the edit action" do
      setup do
        get :edit, :id => Post.first
      end
    
      should_redirect_to("the login page") { login_path }
    end
    
    context "the update action" do
      setup do
        put :update, :id => Post.first, :text => "updated post text!"
      end
      
      should_redirect_to("the login page") { login_path }
    end

    context "the delete action" do
      setup do
        delete :destroy, :id => Post.first
      end
      
      should_redirect_to("the login page") { login_path }
    end
    
  end
  
  context "after login" do
    setup do
      activate_authlogic
      @user = Factory(:user) # creating a user automatically instantiates a session
    end
    
    context "the new action" do
      setup do
        get :new
      end
    
      should_respond_with :success
      should_render_template :new
    end
    
    context "the create action without a user" do
      setup do
        post :create, :post => Factory.build(:post, :user_id => nil).attributes
      end
      
      should_render_template :new
    end
    
    context "the create action" do
      setup do
        post :create, :post => Factory.build(:post).attributes
        # assert_nil assigns(:post).errors
      end
      
      should_redirect_to("the show page") { post_path assigns(:post) }
    end
    
    context "the edit action" do
      setup do
        get :edit, :id => Post.first
      end
    
      should_render_template :edit
    end

    context "the update action" do
      setup do
        put :update, :id => Post.first, :text => "updated post text!"
      end
      
      should_redirect_to("the show page") { post_path assigns(:post) }
    end

    context "the delete action" do
      setup do
        delete :destroy, :id => Post.first
      end
    
      should_redirect_to("the user's groups page") { user_groups_path @user }
    end
    
  end
end
