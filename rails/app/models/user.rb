class User < ActiveRecord::Base
  include UUIDHelper
  include GeoKit::Geocoders

  acts_as_authentic
  acts_as_fischyfriend
  
  easy_roles :roles_mask, :method => :bitmask
  
  # Constant variable storing roles in the system
  # **DO NOT CHANGE ORDER OR REMOVE ROLES** new roles should be appended
  ROLES_MASK = %w[admin moderator]
  
  
  has_attached_file :avatar_image, :styles => { :small => "75x75#", :full => "480x480>" },
                            :convert_options => { :all => '-auto-orient' },
                            :storage => :filesystem
                            
                            # Default values (we can ommit them)
                            # ,
                            # :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                            # :url => "/system/:attachment/:id/:style/:filename"
                            #
                            # We could use uuid?
                            # :url => "/system/:attachment/:uuid/:style/:filename"
  
  belongs_to :home_address,
             :class_name => 'Address',
             :foreign_key => 'home_address_id'
  
  has_many :personal_sets
  has_many :posts do
    def last_taken
      find(:first, :order => 'time_at DESC')
    end
  end
  
  has_many :social_sets,
            :through => :personal_sets,
            :order => 'time_at DESC'
  
  after_create :register_user_to_fb
  
  # the URL path to the user's avatar
  def avatar_path
    if (self.avatar_image.file?)
      self.avatar_image.url('small')
    elsif (!self.avatar.blank?)
    	self.avatar
    else
    	""
  	end
  end
  
  # PersonalSet the default lat/lng based on IP address if none exists
  def personal_set_home_location(ip)
    if self.home_latitude.blank? or self.home_latitude.blank?
      # look up the lat/lng based on IP
      ip = '76.195.14.73' if ip == '127.0.0.1'
      location = IpGeocoder.geocode(ip)
      
      if location.success
        self.home_latitude = location.lat
        self.home_longitude = location.lng
      end
    end
  end
  
  # Return "last updated" information for display
  def latest_stats
    post = self.posts.last_taken
    return "" if post.nil?
    time = post.updated_at.strftime("%I:%m %p").downcase
    today = Time.new
    yesterday = today - 86400
    day = ""
    if (post.updated_at - 86400).strftime("%A, %B %e") == today.strftime("%A, %B %e")
      day = "Yesterday, "
    elsif post.updated_at.strftime("%A, %B %e") != today.strftime("%A, %B %e")
      day = post.updated_at.strftime("%A, %B %e") << ', '
    end
    "Last updated #{day} #{time} from #{post.personal_set.title}"
  end
  
  def pretty_name
    return self.first_name unless self.first_name.blank?
    return self.name unless self.name.blank?
    return self.login
  end
  
  
  
  
  # Facebook connect support
  
  #find the user in the database, first by the facebook user id and if that fails through the email hash
  def self.find_by_fb_user(fb_user)
    User.find_by_facebook_uid(fb_user.uid) || User.find_by_email_hash(fb_user.email_hashes)
  end
  
  #We are going to connect this user object with a facebook id. But only ever one account.
  def link_fb_connect(fb_user)
    unless fb_user.nil? or fb_user.id.nil?
      #check for existing account
      existing_fb_user = User.find_by_facebook_uid(fb_user.id)
      #unlink the existing account
      unless existing_fb_user.nil?
        existing_fb_user.facebook_uid = nil
        existing_fb_user.save(false)
      end
      #link the new one
      self.facebook_uid = fb_user.id
      save(false)
    end
  end
  
  # Take the data returned from facebook and create a new user from it.
  # We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
  def self.create_from_fb_connect(fb_user)
    
    # create a login based on their fb uid and a random password
    new_facebooker = User.new(:login => "facebooker_#{fb_user.uid}", :password => UUIDTools::UUID.timestamp_create().to_s, :email => "")
    new_facebooker.first_name = fb_user.first_name
    new_facebooker.last_name = fb_user.last_name
    new_facebooker.name = fb_user.name
    
    new_facebooker.facebook_uid = fb_user.uid.to_i
    new_facebooker.email_hash = fb_user.email_hashes[0] unless fb_user.email_hashes.blank?
    
    # Validate now, which assigns default values like the auth_logic single_access_token
    new_facebooker.valid?
    
    # we are invalid, since there is no email, but we will ask for that later.
    # for now, save without validation.
    new_facebooker.save(false)
    
    # register the user
    new_facebooker.register_user_to_fb
    
    # return the final value
    new_facebooker
  end
  
  #The Facebook register users method is going to send the users email hash and our account id to Facebook
  #We need this so Facebook can find friends on our local application even if they have not connected through connect
  #We then use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    return if email.blank?
    users = {:email => email, :account_id => id}
    Facebooker::User.register([users])
    self.email_hash = Facebooker::User.hash_email(email)
    save(false)
  end
  
  def facebook_user?
    return !facebook_uid.nil? && facebook_uid > 0
  end
  
  #
  # SEND Instructions to reset the pass
  #
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    
    print "\n * TO RESET VISIT: "+self.perishable_token + "\n"
    
    TransactionalMailer.deliver_password_reset_instructions(self)  
  end
  
  
  
end
