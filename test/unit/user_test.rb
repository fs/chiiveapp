require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # we do not test user creation and login - leave that to authlogic tests
  
  should_have_many :posts
  should_have_many :social_sets
  
  def test_should_be_valid
    assert Factory(:user).valid?
  end
  
  context "When user is created" do
    setup do
      @user = Factory.create(:user)
    end
    
    should "be able to check in to existing social_set" do
      social_set = Factory.create(:social_set)
      social_set.check_in_user(@user)
      assert !@user.checked_in_social_set.nil?
    end
    
    should "be able to check out of checked-in social_set" do
      social_set = Factory.create(:social_set)
      social_set.check_in_user(@user)
      social_set.check_out_user(@user)
      assert !user.checked_in_social_set.nil?
    end
    
    should "be checked in to last recently created event" do
      social_set = Factory.create(:social_set, :user => @user)
      assert_equal social_set.id, @user.checked_in_event.id
    end
    
    should "be able to check out of last recently created event" do
      social_set = Factory.create(:social_set, :user => @user)
      social_set.check_out_user(@user)
      assert @user.checked_in_social_set.nil?
    end
  end
  
  # context "When user has two social_sets" do
  #   setup do
  #     @user = Factory.create(:user)
  #     @social_set_1 = Factory.create(:social_set, :user => @user)
  #     @social_set_2 = Factory.create(:social_set, :user => @user)
  #   end
  #   
  #   should "cache number of social_sets" do
  #     assert_equal 2, @user.social_sets_count
  #   end
  #   
  #   should "update number of social_sets when adding another" do
  #     social_set_3 = Factory.create(:social_set, :user => @user)
  #     assert_equal 3, @user.social_sets_count
  #   end
  #   
  #   should "update number of social_sets when destroying current social set" do
  #     @social_set_2.destroy
  #     @user.reload!
  #     assert_equal 1, @user.social_sets_count
  #   end
  # end
  
  # context "When non-friends share one event" do
  #   setup do
  #     @user = Factory.create(:user)
  #     @non_friend = Factory.create(:user)
  #     
  #     @social_set = Factory.create(:social_set)
  #     @social_set.check_in_user(@user)
  #     @social_set.check_in_user(@non_friend)
  #   end
  #   
  #   should "not have shared friendship object" do
  #     assert @user.get_friendship_from(@non_friend).nil?
  #     assert @non_friend.get_friendship_from(@user).nil?
  #   end
  # 
  #   should "show one shared event" do
  #     assert_equal 1, @user.number_of_shared_events_with(@non_friend)
  #   end
  # end
  
  # context "When friends share one event" do
  #   setup do
  #     @user = Factory.create(:user)
  #     @friend = Factory.create(:user)
  #     
  #     @user.friendships.create(:friend_id => @friend.id)
  #     @friend.friendships.create(:friend_id => @user.id)
  #     
  #     @social_set = Factory.create(:social_set)
  #     @social_set.check_in_user(@user)
  #     @social_set.check_in_user(@friend)
  #   end
  #   
  #   should "have shared friendship object" do
  #     assert !@user.get_friendship_from(@friend).nil?
  #     assert !@friend.get_friendship_from(@user).nil?
  #   end
  # 
  #   should "show one shared event" do
  #     assert_equal 1, @user.number_of_shared_events_with(@friend)
  #   end
  # end
end
