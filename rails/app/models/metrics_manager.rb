class MetricsManager 
          
  # PersonalSet might have many comments (polymorphic relationship)
  #has_many :custom_metrics, 
  #          :as => :custom_metrics_set
            
  # We should use:
  #:custom_metrics_set = Array.new
  
  #@custom_metrics_set = Array.new
  attr_accessor :items
 
 
 
  def initialize(params)
    # Grab the values
    time_value = Time.parse(params[:time_at]) # format: ~= "2010/03/02 15:13:00 -0800" or "2010/03/02 15:13", etc
    latitude_value = params[:latitude].to_f()
    longitude_value = params[:longitude].to_f()

    # max number of suggestions
    limit = params[:limit].to_i
    
    # consider bounding boxes ?
    boxed = params[:boxed].to_i

    #
    # # --- Option 1. Consider all the SocialSets on the DB...
    # social_sets = SocialSet.find(:all) 
    #

    
    # --- Option 2. Let's limit the amount of SocialSets to consider 
    # ---   using a fix raidus around the user...
    # a degree of latitude is ~69 miles
    latutide_range = 0.04 # let's give a few miles range
  
    # a degree of longitude is ~69 miles at the equator
    # a degree of longitude is ~49 miles at 45 degrees latitude
    # a degree of longitude is 0 miles at 0 degress latitude
    longitude_range = 1 # let's give a few of miles range at 45 degrees lat
  
    # hours * minutes * seconds
    time_range = 12 * 60 * 60
  
    # search for social sets within the ranges
    social_sets = SocialSet.find(:all) do
      time_at > time_value - time_range
      time_at < time_value + time_range
      latitude > latitude_value - longitude_range
      latitude < latitude_value + longitude_range
      longitude > longitude_value - longitude_range
      longitude < longitude_value + longitude_range
      order_by time_at.desc
    end
    
    valid_social_sets = social_sets
    
    self.items = Array.new
    
    user = nil
    if (params[:user_id].to_s == params[:user_id].to_i.to_s)
      user = User.find_by_id(params[:user_id])
    else
      user = User.find_by_uuid(params[:user_id])
    end
    
    # Loop through all
    valid_social_sets.each do |social_set|
      self.items << CustomMetrics.new(social_set, user, latitude_value, longitude_value, time_value)
    end
    
    # Sort Social Sets by Weight to get the most relevant first
    self.items.sort! { |a,b| a.w <=> b.w }
    #self.items.reverse!
    
    # Cut the # of suggestions if we have too many
    if (!limit.blank? && limit > 0)
      self.items = self.items.slice(0, limit)
    end
    
    return self.items
  end
  
end