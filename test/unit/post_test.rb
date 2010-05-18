require 'test_helper'

class PostTest < ActiveSupport::TestCase

  ######################################################  
  # Model Validation
  ######################################################  
  
  should_belong_to :user
  should_belong_to :personal_set
  should_ensure_length_in_range :title, 0...255
  should_validate_numericality_of :latitude
  should_validate_numericality_of :longitude
  should_validate_presence_of :personal_set
  should_validate_presence_of :latitude
  should_validate_presence_of :longitude
  should_validate_presence_of :time_at
  
  # # :user doesn't seem to be valid as a field name to check agains (for 'shoulda' at least)
  # should_validate_presence_of :user_id
  should_validate_presence_of :user_id
  
  ######################################################  
  # Basic record creation
  ######################################################  
  
  def test_should_be_valid
    assert Factory(:post).valid?
  end

  ######################################################  
  # Creation
  ######################################################  

  context "When creating new post" do
    
    should "fail with no user" do
      assert !Factory.build(:post, :user => nil).valid?
    end
   
    should "fail with no photo file name" do
      assert !Factory.build(:post, :photo_file_name => nil).valid?
    end
  end
  
  context "When assigning a post's social set" do
    should "create a new personal_set if one exists for this social_set and user" do
      post_1 = Factory.create(:post)
      assert post_1.valid?
      
      post_2 = Factory.create(:post, :social_set => post_1.social_set)
      assert post_2.valid?
      
      assert_not_equal post_1.user, post_2.user
      assert_equal post_1.social_set, post_2.social_set
      assert_not_equal post_1.personal_set, post_2.personal_set
    end
    
    should "not create a new personal_set if one exists for this social_set and user" do
      post_1 = Factory.create(:post)
      assert post_1.valid?
      
      # # This doesn't work
      # 
      # post_2 = Factory.create(:post, :user => post_1.user, :social_set => post_1.social_set)
      # assert post_2.valid?
      #
      # # Why: Factory.crate saves the object to the DB while it is not in a correct state
      # #      first is is created with a different user and social_set
      # #      then the relationships are updated, but without the correct hooks due to saves in the DB
      # #      ie. when the social_set gets a new post it tries to update the corresponding metrics
      # #          however this new post doesn't have the metrics yet because it was created in a new 
      # #          personal_set, eventhough now we are assigning it to the same user, therefore it should
      # #          have personal_set of the same user....
      # # Really messy, this is my best guess...
      # # Conscuence: new object have been created with irregular relationships
      # 
  
  
      # First assign to Set, then change the user...
      post_2 = Factory.build(:post, :social_set => post_1.social_set)
      post_2.user = post_1.user
      assert post_2.valid?
      post_2.save
      
      
      # First assign User, then update the SocialSet
      post_3 = Factory.build(:post, :user => post_1.user)
      post_3.social_set = post_1.social_set
      assert post_3.valid?
      post_3.save
  
  
      # Lets check that all the relationships are correct
      assert_equal post_1.user, post_2.user
      assert_equal post_1.user, post_3.user
      assert_equal post_1.personal_set, post_2.personal_set
      assert_equal post_1.personal_set, post_3.personal_set
      assert_equal post_1.social_set, post_2.social_set
      assert_equal post_1.social_set, post_3.social_set
    end
    
    
    should "have a valid social_set" do
      post = Factory.create(:post)
      assert post.social_set.valid?
    end
    
    should "personal_set should belong to social_set" do
      post = Factory.create(:post)
      assert post.personal_set.social_set post.social_set
    end
    
  end
  
  
  ######################################################  
  # Updating
  ######################################################  
  
  context "When manipulating a post" do
      setup do
        @post = Factory.create(:post)
      end
     
      should "update personal_set if social_set changes" do
        old_personal_set = @post.personal_set
        new_social_set = Factory.create(:social_set)
       
        @post.social_set = new_social_set
       
        assert_not_equal old_personal_set, @post.personal_set
      end
    
    end
  
  
  ######################################################  
  # Deleting
  ######################################################  
  
    context "When destroying post" do
        setup do
          @post = Factory.create(:post)
        end
        
        #
        # Should we delete the empty PersonalSet or leave it in place
        # Leaving it in place would be similar to being still checked in
        # What metrics would we leave if no post is left? The last 
        # calculated one? <- probably
        #
        should "*delete* old personal_set if last post" do
          personal_set_id = @post.personal_set.id
          @post.destroy
          assert !PersonalSet.find(personal_set_id).nil?
        end
        
        should "leave old social_set if last post" do
          social_set_id = @post.social_set.id
          
          @post.destroy
          
          assert !SocialSet.find(social_set_id).nil?
        end
        
    end

  
  ######################################################  
  # Counters
  ######################################################  
  
  #
  # TODO
  #
  # ADD test for all the counters
  # 1. when adding a p to a set, the set counter must go up
  # 2. when deleting
  # 3. when moving between social_sets...
  #

  context "TODO: When dealing with counters" do
      setup do
        @post = Factory.create(:post)
      end
      
      ######
      # TODO
      ######
      should "on CREATE: update posts_count in personal_set" do
        post = Factory.create(:post)
        personal_set = post.personal_set
        
        assert_equal personal_set.posts_count, 1
      end
      
      ######
      # TODO
      ######
      should "on DELETE: update posts_count in parent user_set if not last post" do
        personal_set = @post.personal_set
        
        assert_equal personal_set.posts_count, 1
        
        Factory.create(:post, :user => @post.user, :social_set => @post.social_set)
        personal_set.reload!
        assert_equal personal_set.posts_count, 2
        
        @post.destroy
        personal_set.reload!
        assert_equal personal_set.posts_count, 1
      end
    
    end  
    
end
