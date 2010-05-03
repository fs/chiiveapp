require 'test_helper'

class SocialSetsControllerTest < ActionController::TestCase#tests(SocialSet)
  
  def setup
    
    # Create a USER
    @user = Factory.build(:user)
    @user.save()

    # Create the current_user
    activate_authlogic
    @current_user = Factory(:user) # creating a user automatically instantiates a session
    


    # Create SS
    @social_set = Factory.build(:social_set)
    @personal_set = Factory.build(:personal_set, :social_set =>@social_set, :user => @user)
    @personal_set.save();
    @social_set.personal_sets << @personal_set
    @social_set.save();

    
    # Create Post
    @post = Factory.build(:post, :personal_set => @personal_set, :user => @personal_set.user)
    @post.latitude = 10.546
    @personal_set.posts << @post
    @post.save
    
    @metrics_cx = @social_set.metrics.cx
    
  end
  
  context "after a group is created" do
    
    context "and a new user checks in" do
      setup do
        #get :index
        post :create, :social_set => {:id => @social_set.uuid, :personal_sets_attributes => [{:longitude => "0", :latitude => "0", :time_at => "01/01/1970"}] }
        
        @tot_social_sets = SocialSet.find(:all)
        
        @social_set.reload()
      end
      
      # TODO: figure out the correct redirection
      # should_redirect_to("the show page") { user_social_set_path (@social_set.default_user,@social_set) }
      
      should "end with 1 SS" do
        assert_equal 1, @tot_social_sets.length
      end
      
      should "end with 2 PS in the SS" do
        assert_equal 2, @social_set.personal_sets.length
      end

      should "not change the metrics" do
        assert_equal @metrics_cx, @social_set.metrics.cx
      end

    
      should "create metrics with correct values" do
        assert_equal @personal_set, @post.personal_set
        assert_equal @post.latitude, @post.personal_set.metrics.latitude
        assert_equal @post.latitude, @post.social_set.metrics.latitude
        assert_equal @post.longitude, @post.personal_set.metrics.longitude
        assert_equal @post.longitude, @post.social_set.metrics.longitude
        assert_equal @post.time_at, @post.personal_set.metrics.time_at
        assert_equal @post.time_at, @post.social_set.metrics.time_at
        
        assert_equal @post.personal_set.metrics.wx, @post.social_set.metrics.wx
        assert_equal @post.personal_set.metrics.wy, @post.social_set.metrics.wy
        assert_equal @post.personal_set.metrics.wt, @post.social_set.metrics.wt
      end
      
      
      
    end
      
  end
  
end
