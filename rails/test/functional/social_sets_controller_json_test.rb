require 'test_helper'

class SocialSetsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
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
        get :show, :id => @social_set.id, :client => 'iphone', :client_version => '1.1', :format => 'json'
        @social_set_data = JSON.parse(@response.body)['event']
      end
      
      should_render_template :show
      
      should "respond with JSON" do
        assert_equal @response.content_type, 'application/json'
      end
      
      should "display JSON formatted user data" do
        assert_not_nil @social_set_data['uuid']
        assert_not_nil @social_set_data['title']
        assert_not_nil @social_set_data['posts']
        assert_not_nil @social_set_data['users']
        assert_not_nil @social_set_data['users_count']
        assert_not_nil @social_set_data['owner_uuid']
      end
      
      should "match the database data" do
        assert_equal @social_set.uuid, @social_set_data['uuid']
        assert_equal @social_set.title, @social_set_data['title']
        assert_equal @social_set.posts.size, @social_set_data['posts_count']
        assert_equal @social_set.users.size, @social_set_data['users_count']
      end
      
      should "display all attendees" do
      end
      should "display all posts" do
      end
    end
  end
end
      