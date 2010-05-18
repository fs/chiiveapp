class Post < ActiveRecord::Base
  
  #####################################################
  # BEHAVIORS
  #####################################################
  acts_as_uuidobject
  
  acts_as_mappable :lat_column_name => "latitude",
                   :lng_column_name => "longitude"
  
  has_attached_file :photo, :styles => { :small => "150x150>", :iphone_preview => "75x75#", :iphone => "480x480>" },
                            # include convert options to hanlde orientation of iphone images
                            :convert_options => { :all => '-auto-orient' }
                            # Access storage data from APP_STORAGE hash
                            # :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                            # :storage => APP_STORAGE[RAILS_ENV]['storage'],
                            # :path => APP_STORAGE[RAILS_ENV]['path'],
                            # :url => APP_STORAGE[RAILS_ENV]['url']
  
  
  #####################################################
  # ASSOCIATIONS
  #####################################################
  belongs_to :user
  
  belongs_to :personal_set, :counter_cache => true
  
  has_many :comments, :as => :commentable, :dependent => :destroy
  
  
  #####################################################
  # VALIDATIONS
  #####################################################
  validates_presence_of :user_id, :time_at, :latitude, :longitude, :uuid
  validates_length_of :title, :maximum => 255, :allow_nil => true
  validates_numericality_of :latitude, :longitude
  validates_presence_of :personal_set
  validates_attachment_presence :photo
  
  
  #####################################################
  # ACCESSORS
  #####################################################
  def social_set
    return self.personal_set.nil? ? nil : self.personal_set.social_set
  end
  
  def lat_lng
    "#{self.latitude}, #{self.longitude}" unless self.latitude.blank? or self.longitude.blank?
  end
  
  def pretty_time_at
    self.time_at.strftime('%A, %B %e, %Y, %I:%M:%S %p')
  end
  
  def pretty_title
    self.title.blank? ? 'Untitled' : self.title
  end
  
  def pretty_text
    self.text.blank? ? 'No Description' : self.text
  end
  
  def position
    social_set.posts.to_a.index(self).to_i
  end
  
  def previous_post
    position > 0 ? social_set.posts.to_a[position - 1] : nil
  end
  
  def next_post
    position < social_set.posts.count ? social_set.posts.to_a[position + 1] : nil
  end
  
  #####################################################
  # METRICS
  #####################################################
  def cx
    self.latitude
  end
  def cy
    self.longitude
  end
  def ct
    self.time_at.to_f 
  end
  
  
protected

  #####################################################
  # CUSTOM VALIDATIONS
  #####################################################
  def validate
    validate_not_blank
    validate_lat_lng
    validate_usage_limits
  end
  
  def validate_not_blank
    errors.add "entry cannot be blank!" if photo.blank? and title.blank? and text.blank?
  end
  
  def validate_lat_lng
  end

  def validate_usage_limits
    account_size = Post.sum("photo_file_size", :conditions => ["user_id = ? AND created_at >= ?", self.user.id, 1.day.ago])

    if account_size >= APP_LIMITS[RAILS_ENV]['file_storage_per_day']
      print "\nQUOTA LIMIT EXCEEDED\n"
      
      # Random Rails bug: DO NOT end Error Strings with a '.' !!! 
      # errors.add("File size too large. You have exceeded the available quota for you account.")
      errors.add("File size too large. You have exceeded the available quota for you account")
    end
    
  end
  
  #####################################################
  # UTIL FNs
  #####################################################
  # def time_difference_equation
  #   "ABS(TIME_TO_SEC(TIMEDIFF(date,'#{self.time_at.to_formatted_s(:db)}')))"
  # end
  # 
  # def distance_equation
  #   convert_to_miles = 1.1515
  #   convert_to_km = 1.85315962
  #   
  #   equation = "((ACOS(SIN(#{self.latitude} * PI() / 180) * SIN(latitude * PI() / 180) + "
  #   equation << "COS(#{self.latitude} * PI() / 180) * COS(latitude * PI() / 180) * COS((#{self.longitude} - longitude) * PI() / 180))"
  #   equation << " * 180 / PI()) * 60 * #{convert_to_km})"
  # end
  # 
  # def distance_equation_simple
  #   convert_to_miles = 1.1515
  #   convert_to_km = 1.85315962
  #   # Tip: Remove the SQRT and just compare against a squared distance!
  #   # SQRT(POW(L2.lat - L1.lat, 2) + POW(L2.lng - L1.lng, 2))
  #   # SQR((69.1*(Zip2Lat-Zip1Lat))*(69.1*(Zip2Lat-Zip1Lat))+(69.1*(Zip2Lon-Zip1Lon)*COS(Zip1Lat/57.3)*(69.1*(Zip2Lon-Zip1Lon)*COS(Zip1Lat/57.3))))
  #   
  #   equation = "((ACOS(SIN(#{self.latitude} * PI() / 180) * SIN(latitude * PI() / 180) + "
  #   equation << "COS(#{self.latitude} * PI() / 180) * COS(latitude * PI() / 180) * COS((#{self.longitude} - longitude) * PI() / 180))"
  #   equation << " * 180 / PI()) * 60 * #{convert_to_km})"
  # end

end