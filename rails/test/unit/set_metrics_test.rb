require 'test_helper'

class SetMetricsTest < ActiveSupport::TestCase


  ######################################################  
  # Model Validation
  ######################################################  
  
  # should_have_one :personal_set
  # 
  # should_validate_numericality_of :latitude
  # should_validate_numericality_of :longitude
  # should_validate_numericality_of :wx
  # should_validate_numericality_of :wy
  # should_validate_numericality_of :wt
  # 
  # should_validate_presence_of :latitude
  # should_validate_presence_of :longitude
  # should_validate_presence_of :time_at
  # should_validate_presence_of :wx
  # should_validate_presence_of :wy
  # should_validate_presence_of :wt


  ######################################################  
  # Creation
  ######################################################  
  
  context "When creating a new post" do
      setup do
        
        # DOES NOT work
        # @post = Factory.create(:post)

        # DOES NOT work
        # @social_set = Factory.create(:social_set)
        
        # DOES work

        # Create a USER
        @user = Factory.build(:user)
        @user.save()

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
        
      end
     
      should "create set_metrics for the post's personal_set" do
        assert !@post.personal_set.metrics.nil?
      end
      
      should "create social_set_metrics for the post's social_set" do
        assert !@post.social_set.metrics.nil?
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
    
    ######################################################  
    # Update
    ######################################################  

    context "When adding a new post" do
        setup do
          # Create a USER
          @user = Factory.build(:user)
          @user.save()

          # Create SS
          @social_set = Factory.build(:social_set)
          @personal_set = Factory.build(:personal_set, :social_set =>@social_set, :user => @user)
          @personal_set.save();
          @social_set.personal_sets << @personal_set
          @social_set.save();


          # Create Post
          @post = Factory.build(:post, :personal_set => @personal_set, :user => @personal_set.user)
          @post.latitude = 10.0
          @personal_set.posts << @post
          @post.save

          # Create Post
          @post_2 = Factory.build(:post, :personal_set => @personal_set, :user => @personal_set.user)
          @post_2.latitude = 20.0
          @personal_set.posts << @post_2
          @post_2.save
        end
    
        should "update the metrics with correct values" do
    
          @post.latitude = 10.123
          @post.longitude = 100.948
          @post.save
    
          @post_2.latitude = 20.243
          @post_2.longitude = 200.897
          @post_2.save
    
    
          assert_equal @post.personal_set.metrics.cx, (@post.latitude+ @post_2.latitude)/2.0
          assert_equal @post.personal_set.metrics.cy, (@post.longitude+ @post_2.longitude)/2.0
          
          assert_equal @post.personal_set.metrics.wx, @post.social_set.metrics.wx
          assert_equal @post.personal_set.metrics.wy, @post.social_set.metrics.wy
          assert_equal @post.personal_set.metrics.wt, @post.social_set.metrics.wt
        end
    
      end

      ######################################################  
      # Checking
      ######################################################  

      context "When checking in a new user in a previous SocialSet" do
          setup do
            # Create a USER
            @user = Factory.build(:user)
            @user.save()

            # Create SS
            @social_set = Factory.build(:social_set)
            @personal_set = Factory.build(:personal_set, :social_set =>@social_set, :user => @user)
            @personal_set.save();
            @social_set.personal_sets << @personal_set
            @social_set.save();


            # Create Post
            @post = Factory.build(:post, :personal_set => @personal_set, :user => @personal_set.user)
            @post.latitude = 10.0
            @personal_set.posts << @post
            @post.save

            # Create a USER
            @user_2 = Factory.build(:user)
            @user_2.save()
            
            # if there is no personal_set exists for this user, then check him in!
              # Checkin in (create a new personal_set)
            params = {:social_set => {:id => @social_set.uuid, :personal_sets_attributes => [{:longitude => "0", :latitude => "0", :time_at => "01/01/1970", :user_id => @user_2.id, :title => "NO_TITLE"}] } }
  
            @social_set.attributes = params[:social_set]
            @social_set.save

            # # Create Post
            # @post_2 = Factory.build(:post, :personal_set => @personal_set, :user => @personal_set.user)
            # @post_2.latitude = 20.0
            # @personal_set.posts << @post_2
            # @post_2.save
          end

          should "keep the original metrics" do
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


          should "update the metrics with correct values" do

            @post.latitude = 10.123
            @post.longitude = 100.948
            @post.save


            assert_equal @post.personal_set.metrics.wx, @post.social_set.metrics.wx
            assert_equal @post.personal_set.metrics.wy, @post.social_set.metrics.wy
            assert_equal @post.personal_set.metrics.wt, @post.social_set.metrics.wt
          end
          
          
          
          context "and checking out later" do
              setup do

                # Check out
                @personal_set_2 = @user_2.personal_sets.find(:first, :conditions => ['social_set_id = ?', @social_set.id])
                @personal_set_2.destroy #unless (@personal_set.nil? or @personal_set.posts.size > 0)

              end

              should "keep the original metrics" do
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
