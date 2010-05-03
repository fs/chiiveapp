require 'test_helper'

class SocialSetTest < ActiveSupport::TestCase

  ######################################################  
  # Basic creation
  ######################################################  
  
  def test_should_be_valid
    social_set = Factory.build(:social_set)
    social_set.personal_sets << Factory.build(:personal_set)
    assert social_set.valid?
  end
  
  ######################################################  
  # Creating 
  ######################################################  
  
  context "When creating new social_set" do
    
    setup do
     @social_set = Factory.build(:social_set)
    end
    
    should "fail without a personal set" do
     assert !@social_set.valid?
    end
    
    should "fail without a user for the personal set" do
      @social_set.personal_sets << Factory.build(:personal_set)
      @social_set.default_personal_set.user = nil
      assert !@social_set.valid?
    end
    
    should "fail with no latitude" do
      @social_set.personal_sets << Factory.build(:personal_set, :latitude => nil)
      assert !@social_set.valid?
    end
    
    should "fail with no longitude" do
      @social_set.personal_sets << Factory.build(:personal_set, :longitude => nil)
      assert !@social_set.valid?
    end
    
    should "fail with no time" do
      @social_set.personal_sets << Factory.build(:personal_set, :time_at => nil)
      assert !@social_set.valid?
    end
    
    should "fail with no title" do
      @social_set.personal_sets << Factory.build(:personal_set, :title => nil)
      assert !@social_set.valid?
    end
    
    should "have metrics identical to the default personal set" do
      @social_set.personal_sets << Factory.build(:personal_set)
      assert_equal @social_set.default_personal_set.latitude, @social_set.latitude
      assert_equal @social_set.default_personal_set.longitude, @social_set.longitude
      assert_equal @social_set.default_personal_set.time_at.to_i, @social_set.time_at.to_i
    end
    
   end
   
  ######################################################  
  # Adding Posts
  ######################################################  
  
  context "When adding posts to user's existing event" do
    
    setup do
      @social_set = Factory.build(:social_set)
      @social_set.personal_sets << Factory.build(:personal_set)
      @social_set.save()
      @social_set.reload
      
      @latitude = @social_set.latitude
      @longitude = @social_set.longitude
      @time_at = @social_set.time_at
      
      @post1 = Factory.build(:post, :user => @social_set.default_user,
                                   :latitude => @latitude + 2,
                                   :longitude => @longitude + 2,
                                   :time_at => Time.at(@time_at.to_i + 2),
                                   :personal_set => nil)
       
      @post2 = Factory.build(:post, :user => @social_set.default_user,
                                    :latitude => @latitude + 4,
                                    :longitude => @longitude + 4,
                                    :time_at => Time.at(@time_at.to_i + 4),
                                    :personal_set => nil)
                                    
      @post3 = Factory.build(:post, :user => @social_set.default_user,
                                  :latitude => @latitude + 6,
                                  :longitude => @longitude + 6,
                                  :time_at => Time.at(@time_at.to_i + 6),
                                  :personal_set => nil)
    end
    
    should "social set should be valid initially" do
      assert @social_set.valid?
    end
    
    should "insert into same personal_set" do
      @social_set.default_personal_set.posts << @post1
      assert_equal @post1.personal_set, @social_set.default_personal_set
    end
    
    should "have unique metrics for post and social_set (sanity check)" do
      assert_not_equal @post1.latitude, @social_set.latitude
      assert_not_equal @post1.longitude, @social_set.longitude
      assert_not_equal @post1.time_at, @social_set.time_at
      
      assert_not_equal @post2.latitude, @social_set.latitude
      assert_not_equal @post2.longitude, @social_set.longitude
      assert_not_equal @post2.time_at, @social_set.time_at
      
      assert_not_equal @post1.latitude, @post2.latitude
      assert_not_equal @post1.longitude, @post2.longitude
      assert_not_equal @post1.time_at, @post2.time_at
    end
    
    should "update metrics to match first post's" do
      @social_set.default_personal_set.posts << @post1
      @social_set.reload
      
      assert_equal @post1.latitude, @social_set.latitude
      assert_equal @post1.longitude, @social_set.longitude
      assert_equal @post1.time_at, @social_set.time_at
    end
    
    should "update metrics to incrementally with second post" do
      @social_set.default_personal_set.posts << @post1
      @social_set.default_personal_set.posts << @post2
      @social_set.reload
      
      assert_equal (@post1.latitude + @post2.latitude) / 2, @social_set.latitude
      assert_equal (@post1.longitude + @post2.longitude) / 2, @social_set.longitude
      assert_equal (@post1.time_at.to_i + @post2.time_at.to_i) / 2, @social_set.time_at.to_i
    end

    should "update metrics to incrementally with third post" do
      @social_set.default_personal_set.posts << @post1
      @social_set.default_personal_set.posts << @post2
      @social_set.default_personal_set.posts << @post3
      @social_set.reload
      
      assert_equal (@post1.latitude + @post2.latitude + @post3.latitude) / 3, @social_set.latitude
      assert_equal (@post1.longitude + @post2.longitude + @post3.longitude) / 3, @social_set.longitude
      assert_equal (@post1.time_at.to_i + @post2.time_at.to_i + @post3.time_at.to_i) / 3, @social_set.time_at.to_i
    end

  end
  
  ######################################################  
  # Removing Posts
  ######################################################  
  
  context "When removing posts from a single user's event" do
     
  end

  ######################################################  
  # Adding Attendees
  ######################################################  
  
  context "When adding attendees to an event" do
     
  end
  
  ######################################################  
  # Removing Attendees
  ######################################################  
  
  context "When removing attendees from an event" do
     
  end
  
  ######################################################  
  # Adding Attendee Posts
  ######################################################  
  
  context "When adding attendee posts to an event" do
     
  end

  ######################################################  
  # Removing Attendee Posts
  ######################################################  
  
  context "When removing attendee posts from an event" do
     
  end

end
