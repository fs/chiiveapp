class PersonalSet < ActiveRecord::Base
  include GeoKit::Geocoders
  
  #####################################################
  # ASSOCIATIONS
  #####################################################
  belongs_to :user, :counter_cache => true
  
  belongs_to :social_set, :counter_cache => true
  
  has_many :comments, :as => :commentable, :dependent => :destroy
  
  has_many :posts,
            :before_add => :update_metrics_with_post,
            :include => :user,
            :autosave => true,
            :order => "time_at DESC",
            :dependent => :destroy
  
  
  #####################################################
  # ASSOCIATION MODIFIERS
  #####################################################
  accepts_nested_attributes_for :posts, :reject_if => proc { |attributes| 
                                                               attributes['phoot'].blank? and 
                                                               attributes['latitude'].blank? and 
                                                               attributes['longitude'].blank? 
                                                             }
  
  #####################################################
  # VALIDATION
  #####################################################
  validates_presence_of     :user_id, :title
  validates_length_of       :title, :maximum => 255, :allow_nil => true
  validates_length_of       :description, :maximum => 255, :allow_nil => true
  validates_presence_of     :latitude, :longitude, :time_at
  validates_numericality_of :latitude, :longitude
  
  
  
  #####################################################
  # ACCESSORS
  #####################################################

  def pretty_title
    self.title
  end  
  
  #####################################################
  # UPDATE METRICS
  # Update the basic personal_set metrics
  #####################################################
  def update_metrics_with_post(post)
    
    # find the incremental impact of our update
    increment = self.posts.size + 1
    increment -= 1 if post.personal_set == self # if we're just recalculating a current post
    
    # make sure we have good values
    return if post.latitude.blank? or post.longitude.blank? or post.time_at.blank?
    
    # don't divide by zero
    increment = 1 if increment < 1 
    
    # make sure we have initial values
    self.latitude = post.latitude if self.latitude.blank?
    self.longitude = post.longitude if self.longitude.blank?
    self.time_at = post.time_at if self.time_at.blank?
    
    # update the values incrementally
    self.latitude = (self.latitude * (increment - 1) + post.latitude) / increment
    self.longitude = (self.longitude * (increment - 1) + post.longitude) / increment
    self.time_at = Time.at(((self.time_at.to_i * (increment - 1) + post.time_at.to_i) / increment).to_i)
    
    # save the changes
    self.save
    
    # update the corresponding social set's metrics
    self.social_set.update_metrics_with_set(self) unless self.social_set.nil?
  end
  
  
  #####################################################
  # ADDRESS
  # TODO: Use this method in the metric classes
  #####################################################
#   belongs_to :address
#   
#   def update_address
#     res = GoogleGeocoder.reverse_geocode([self.latitude, self.longitude])
#     if (res.success)
#       addr = Address.new
#       addr.format_reverse_geocode(res)
#       addr.save
#       self.address = addr
#       self.save!
#     end
#   end
#   
#   # Spin this as a background process using the delayed_job plugin
#   handle_asynchronously :update_address
#   
  def pretty_address
    return "" if address.nil?
    
    pretty = "#{self.address.city}"
    pretty << ", " unless pretty.blank? or self.address.state.blank?
    pretty << "#{self.address.state}" unless self.address.state.blank?
    pretty << ", " unless pretty.blank? or self.address.country.blank?
    pretty << "#{self.address.country}" unless self.address.country.nil?
  end
#   
#   # def on_remove_post
#   #   self.destroy if self.posts.count < 1
#   # end
#   
#   #####################################################
#   # DURATION
#   # TODO: move to metrics or use as a getter
#   #####################################################
#   def pretty_duration
#     dur = start.strftime("%A, %B %e, %Y, %I:%M")
#     
#     return dur << start.strftime("%p").downcase if start.strftime("%A, %B %e, %Y, %I:%M:%p") == finish.strftime("%A, %B %e, %Y, %I:%M:%p")
#     
#     if start.strftime("%A, %B %e") != finish.strftime("%A, %B %e")
#       dur << "#{start.strftime("%p").downcase} - #{finish.strftime("%A, %B %e, %I:%M")}"
#     elsif start.strftime("%p") != finish.strftime("%p")
#       dur << "#{start.strftime("%p").downcase} - #{finish.strftime("%I:%M")}"
#     else
#       dur << " - #{finish.strftime("%I:%M")}"
#     end
#     
#     dur << finish.strftime("%p").downcase
#   end
#   

end
