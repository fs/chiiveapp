class CustomMetrics
  
  #belongs_to :social_set
  attr_accessor :social_set
  
  attr_accessor :cx
  attr_accessor :cy
  attr_accessor :ct
  attr_accessor :wx
  attr_accessor :wy
  attr_accessor :wt

  attr_accessor :w
  
  attr_accessor :f # number of friends

  def initialize(social_set, user, lat, lon, time)
    
    self.social_set = social_set
    
    self.cx = social_set.latitude
    self.cy = social_set.longitude
    self.ct = social_set.time_at.to_f
    self.wx = social_set.personal_sets_count
    self.wy = social_set.personal_sets_count
    self.wt = social_set.personal_sets_count
    
    # temp value
    self.w = social_set.personal_sets_count

    # print "'''''''''''''''''''\n"
    # print "''' cx: ", self.cx, "\n"
    # print "''' cy: ", self.cy, "\n"
    # print "''' ct: ", self.ct, "\n"
    # print "''' wx: ", self.wx, "\n"
    # print "''' wy: ", self.wy, "\n"
    # print "''' wt: ", self.wt, "\n"

    
    self.getW(user, lat, lon, time)
  end
  
  def getW(user, lat, lon, time)
    
    # Distances 
    # dx = (lat - cx).abs 
    # dy = (lon - cy).abs 
    # dt = (time.to_f - ct).abs
    # 
    # # Weighted
    # wx_tot = dx / (self.wx * self.w)
    # wy_tot = dy / (self.wy * self.w)
    # wt_tot = dt / (self.wt * self.w)
    # 
    # # --- Normalize the values
    # # --- Used to add all the values and get one unique metric.
    #   # LAT, LON to miles
    #   wx_tot = SetMetrics.lat_distance_to_miles(wx_tot)
    #   wy_tot = SetMetrics.lat_distance_to_miles(wy_tot)
    #   # MS to Hours
    #   # Not needed because the wt used (as stored in social_set & personal_set) were already Hours, not ms
    #   #wt_tot = self.secs_to_hours(wt_tot)
    # 
    #   wx_tot *= wx_tot
    #   wy_tot *= wy_tot
    #   wt_tot *= wt_tot
    # 
    # 
    # # --- Add values
    # self.w = Math.sqrt(wx_tot + wy_tot + wt_tot) #* social_set.metrics.w



    #########
    # Factoring Friendships
    wu_tot = 1;
    
    self.social_set.personal_sets.each do |personal_set|
      
      friendship = Friendship.find(:first, :conditions => ['user_id = ? AND friend_id = ?', user.id, personal_set.user.id] )
      
      # If they are friends
      if (!friendship.nil?)
        wu_tot += 1 # +1 per friend
      end
      
    end
    
    self.f = wu_tot - 1 # Number of user friends
    
    self.w = self.w / wu_tot # Each friend 'shortens' the distance to the event
    
    print "\n +----------------+"
    print "\n | friends: ", wu_tot
    print "\n |       w: ", self.w
    print "\n +----------------+\n"
    
    #
    #########


    return self.w
  end

  #
  # Existential question:
  #   Does the radius or the bounding box of an event depend on the number of participants?
  #   a: we will assume 'no' for now
  #
  def getRadiusX()
    1 * wx
  end
  
  def getRadiusY()
    1 * wy
  end
  
  def getRadiusZ()
    1 * wt
  end       
 
         
end