require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  context "create user" do
    setup do
      @new_first_name = 'Thomas'
      @new_last_name = 'Teeter'
      @new_email = 'thenewtom@teeter.com'
      @new_user_data = { :first_name => @new_first_name, :last_name => @new_last_name, :email => @new_email }
      
      post :create, { :client => 'iphone', :client_version => '1.1', :format => 'json', :user => @new_user_data }
    end
    
    should_respond_with :success
    
    should "respond with JSON" do
      assert_equal @response.content_type, 'application/json'
    end
    
    should "display JSON formatted user data" do
      assert_not_nil @user_data['uuid']
      assert_not_nil @user_data['first_name']
      assert_not_nil @user_data['last_name']
      assert_not_nil @user_data['avatar']
      
      assert_not_nil @user_data['friends_count']
      assert_not_nil @user_data['friend_requests_count']
      assert_not_nil @user_data['personal_sets_count']
      
      assert_not_nil @user_data['events']
    end
  end
  
  context "after login" do
    setup do
      activate_authlogic
      @tom = Factory(:user)
      @dick = Factory(:user)
      @harry = Factory(:user)
      
      # create a friend
      @tom.friendships.create(:friend_id => @dick.id)
      @dick.friendships.create(:friend_id => @tom.id)
      
      # create a friend request
      @harry.friendships.create(:friend_id => @tom.id)
      
      # add a social set shared by tom and dick
      @social_set = SocialSet.new
      @social_set.personal_sets << Factory.build(:personal_set, :user => @tom)
      @social_set.personal_sets << Factory.build(:personal_set, :user => @dick)
      @social_set.save
      
      # add a post for each tom and dick
      Factory.create(:post, :user => @tom, :personal_set => @social_set.default_personal_set)
      Factory.create(:post, :user => @dick, :personal_set => @social_set.personal_sets.find_by_user_id(@dick.id))
      
      # refresh all our data
      @social_set.reload
      @tom.reload
      @dick.reload
      
      UserSession.create(@tom)
    end
  
    context "the show action" do
      setup do
        get :show, :id => @tom.id, :client => 'iphone', :client_version => '1.1', :format => 'json'
        @user_data = JSON.parse(@response.body)['user']
      end
      
      should_render_template :show
      
      should "respond with JSON" do
        assert_equal @response.content_type, 'application/json'
      end
      
      should "display JSON formatted user data" do
        assert_not_nil @user_data['uuid']
        assert_not_nil @user_data['first_name']
        assert_not_nil @user_data['last_name']
        assert_not_nil @user_data['avatar']
        
        assert_not_nil @user_data['friends_count']
        assert_not_nil @user_data['friend_requests_count']
        assert_not_nil @user_data['personal_sets_count']
        
        assert_not_nil @user_data['events']
      end
      
      should "not display personal user data" do
        assert_nil @user_data['email']
        assert_nil @user_data['single_access_token']
        assert_nil @user_data['facebook_uid']
      end
      
      should "match database data" do
        assert_equal @user_data['uuid'], @tom.uuid
        assert_equal @user_data['first_name'], @tom.first_name
        assert_equal @user_data['last_name'], @tom.last_name
        
        assert_equal @user_data['friends_count'], @tom.mutual_friends.length
        assert_equal @user_data['friend_requests_count'], @tom.fans_of_me.length
        assert_equal @user_data['personal_sets_count'], @tom.personal_sets_count
        
        assert_equal @user_data['events'].size, @user_data['personal_sets_count']
      end
      
      should "match expected data" do
        assert_equal 1, @user_data['friends_count']
        assert_equal 1, @user_data['friend_requests_count']
        assert_equal 1, @user_data['personal_sets_count']
      end
      
      context "the event" do
        setup do
          @event = @user_data['events'][0]['event']
        end
        
        should "exist" do
          assert_not_nil @event
        end
        
        should "match the created event" do
          assert_equal @social_set.uuid, @event['uuid']
          assert_equal @social_set.title, @event['title']
          assert_equal @social_set.posts.size, @event['posts_count']
          assert_equal @social_set.users.size, @event['users_count']
        end
        
        should "display the event owner" do
          assert_not_nil @event['owner']
          assert_equal @tom.first_name, @event['owner']['user']['first_name']
        end
      
        should "display a single event post" do
          assert_not_nil @event['post']
          assert_equal @tom.posts.first.uuid, @event['post']['post']['uuid']
          assert_equal @tom.posts.first.title, @event['post']['post']['title']
        end
      end
    end
    
    context "update user data" do
      setup do
        @new_first_name = 'Thomas'
        @new_last_name = 'Teeter'
        @new_email = 'thenewtom@teeter.com'
        @new_user_data = { :first_name => @new_first_name, :last_name => @new_last_name, :email => @new_email }
        
        put :update, { :id => @tom.id, :client => 'iphone', :client_version => '1.1', :format => 'json', :user => @new_user_data }
        
        @tom.reload
        @user_data = JSON.parse(@response.body)['user']
      end
      
      should_respond_with :success
      
      should "respond with JSON" do
        assert_equal @response.content_type, 'application/json'
      end
      
      should "display JSON formatted user data" do
        assert_not_nil @user_data['uuid']
        assert_not_nil @user_data['first_name']
        assert_not_nil @user_data['last_name']
        assert_not_nil @user_data['avatar']
        
        assert_not_nil @user_data['friends_count']
        assert_not_nil @user_data['friend_requests_count']
        assert_not_nil @user_data['personal_sets_count']
      end
      
      should "display personal user data" do
        assert_not_nil @user_data['email']
        assert_not_nil @user_data['single_access_token']
        assert_not_nil @user_data['facebook_uid']
      end
      
      should "not display events" do
        assert_nil @user_data['events']
      end
      
      should "match database data" do
        assert_equal @user_data['uuid'], @tom.uuid
        assert_equal @user_data['first_name'], @tom.first_name
        assert_equal @user_data['last_name'], @tom.last_name
        assert_equal @user_data['email'], @tom.email
        assert_equal @user_data['single_access_token'], @tom.single_access_token
        
        assert_equal @user_data['friends_count'], @tom.mutual_friends.length
        assert_equal @user_data['friend_requests_count'], @tom.fans_of_me.length
        assert_equal @user_data['personal_sets_count'], @tom.personal_sets_count
      end
      
      should "match expected data" do
        assert_equal @new_first_name, @user_data['first_name']
        assert_equal @new_last_name, @user_data['last_name']
        assert_equal @new_email, @user_data['email']
      end
    end
  end
end