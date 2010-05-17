class SocialSet < ActiveRecord::Base

  #####################################################
  # BEHAVIORS
  #####################################################
  acts_as_uuidobject

  
  #####################################################
  # ASSOCIATIONS
  #####################################################
  has_many :personal_sets, :class_name => 'PersonalSet',
           :dependent => :destroy,
           :autosave => true,
           :before_add => :update_metrics_with_set,
           :order => "order_social_set ASC"
           
  has_many :posts, :through => :personal_sets, :order => "posts.time_at DESC"
  has_many :users, :through => :personal_sets
  has_many :comments, :as => :commentable
  

  #####################################################
  # ASSOCIATION MODIFIERS
  #####################################################
  accepts_nested_attributes_for :personal_sets


  #####################################################
  # VALIDATION
  #####################################################
  validates_presence_of     :default_user, :default_personal_set
  validates_presence_of     :uuid
  validates_presence_of     :latitude, :longitude, :time_at
  validates_numericality_of :latitude, :longitude

  
  #####################################################
  # ACCESSORS
  #####################################################
  def default_personal_set
    return self.personal_sets.first
  end

  def default_user
      self.default_personal_set.nil? ? nil : self.default_personal_set.user
  end
  
  def title
      self.default_personal_set.nil? ? nil : self.default_personal_set.title
  end
  def title=(value)
      self.default_personal_set.title = value unless self.default_personal_set.nil?
  end  
  
  #####################################################
  # UPDATE METRICS
  # Update the basic personal_set metrics
  #####################################################
  def update_metrics_with_set(personal_set)
    increment = self.personal_sets.size + 1
    increment -= 1 if personal_set.social_set == self # if we're just recalculating a current personal set
    
    # make sure we have good values
    return if personal_set.latitude.blank? or personal_set.longitude.blank? or personal_set.time_at.blank?
    
    # don't divide by zero
    increment = 1 if increment < 1
    
    # make sure we have initial values
    self.latitude = personal_set.latitude if self.latitude.blank?
    self.longitude = personal_set.longitude if self.longitude.blank?
    self.time_at = personal_set.time_at if self.time_at.blank?
    
    # update the values incrementally
    self.latitude = (self.latitude * (increment - 1) + personal_set.latitude) / increment
    self.longitude = (self.longitude * (increment - 1) + personal_set.longitude) / increment
    self.time_at = Time.at(((self.time_at.to_i * (increment - 1) + personal_set.time_at.to_i) / increment).to_i)
    
    # save the changes
    self.save
  end
  
protected

  #####################################################
  # CUSTOM VALIDATIONS
  #####################################################
  def validate
    # validate_usage_limits
  end

  def validate_usage_limits
    events_today = SocialSet.count(:all, :conditions => ["created_at >= ?", 1.day.ago])
    
    if events_today >= APP_LIMITS[RAILS_ENV]['events_per_day']
      errors.add("Too many events in one day. You have exceeded the available quota for you account")
    end
  end
end

