class MetricsManager 
  attr_accessor :social_sets
  attr_accessor :time_at
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :limit
  
  def initialize(params)
    # parse the time value to use in our bounding box
    time_value = Time.parse(params[:time_at]) # format: ~= "2010/03/02 15:13:00 -0800" or "2010/03/02 15:13", etc
    
    # max number of suggestions
    params[:limit] = 5 if params[:limit].blank?
    
    ########################
    # Scoring 
    ########################
    
    # max of 3 * score_per_distance, since we have lat, lng, and time
    score_per_distance = 1 
    
    # number of points for each friend at an event
    score_per_friend = 2 
    
    # number of points if you're at the event
    score_for_user = 5 
    
    
    ########################
    # Bounding Box
    ########################
    
    # a degree of latitude is ~69 miles
    latitude_range = 0.014 # let's give about a mile range
    
    # a degree of longitude is ~69 miles at the equator
    # a degree of longitude is ~49 miles at 45 degrees latitude
    # a degree of longitude is 0 miles at 0 degress latitude
    longitude_range = 0.02 # let's give about a mile range at 45 degrees lat
    
    # hours * minutes * seconds
    time_range = 6 * 60 * 60
    
    ########################
    # Selection
    ########################
    
    # create the sql for the select
    # we create a "score" for each social set based on how far away, when, and how many friends are at the event
    sql_select = "SELECT *, "
    
    # Distance score: {score_per_distance} * distance in time and geography from the event relative to bounding size
    sql_select += "(#{score_per_distance} - ABS(s.latitude - :latitude) / #{latitude_range}) + "
    sql_select += "(#{score_per_distance} - ABS(s.longitude - :longitude) / #{longitude_range}) + "
    sql_select += "(#{score_per_distance} - ABS(TIMESTAMPDIFF(SECOND, s.time_at, :time_at)) / #{time_range}) as score_location, "
    
    # Friendships score: {score_per_friend} * number of friends at the event
    sql_select += "(SELECT COUNT(*) FROM personal_sets as p, friendships as f "
      sql_select += "WHERE (s.id = p.social_set_id AND f.user_id = p.user_id AND f.friend_id = :user_id) "
      sql_select += ") * #{score_per_friend} AS score_friends, "
    
    # User score: {score_for_user} points if the user is there
    sql_select += "(SELECT COUNT(*) FROM personal_sets as p WHERE p.social_set_id = s.id AND p.user_id = :user_id) * #{score_for_user} as score_user "
    
    # we're looking fror social sets
    sql_select += "FROM social_sets as s "
    
    # stay within a time and geography bounding box
    sql_select += "WHERE s.latitude > (:latitude - #{latitude_range}) AND s.latitude < (:latitude + #{latitude_range}) "
    sql_select += "AND s.longitude > (:longitude - #{longitude_range}) AND s.longitude < (:longitude + #{longitude_range}) "
    sql_select += "AND s.time_at > '#{(time_value - time_range).to_s(:db)}' AND s.time_at < '#{(time_value + time_range).to_s(:db)}' "
    
    # make sure the event is accessibe to the user
    sql_select += "AND ( "
      # event is public
      sql_select += "(SELECT public FROM personal_sets as p WHERE s.id = p.social_set_id ORDER BY order_social_set ASC LIMIT 1) = 1 "
      # event has user's friends present
  	  sql_select += "OR (SELECT COUNT(*) FROM personal_sets as p, friendships as f WHERE s.id = p.social_set_id AND f.user_id = p.user_id AND f.friend_id = :user_id) > 0 "
      # event is already one of the user's events
  	  sql_select += "OR (SELECT COUNT(*) FROM personal_sets as p WHERE s.id = p.social_set_id AND p.user_id = :user_id) > 0 "
    sql_select += ") "
    
    # order by our score and set the max number to return
    sql_select += "ORDER BY score_location + score_friends + score_user DESC "
    sql_select += "LIMIT :limit "
    
    # search for social sets within the ranges
    self.social_sets = SocialSet.find_by_sql([sql_select, params])
    
  end
end