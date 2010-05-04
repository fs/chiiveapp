class MetricsManager 
  attr_accessor :social_sets
  attr_accessor :time_at
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :limit
  
  def initialize(params)
    # Grab the values
    time_value = Time.parse(params[:time_at]) # format: ~= "2010/03/02 15:13:00 -0800" or "2010/03/02 15:13", etc
    latitude_value = params[:latitude].to_f()
    longitude_value = params[:longitude].to_f()
    
    # max number of suggestions
    params[:limit] = 5 if params[:limit].blank?
    
    # a degree of latitude is ~69 miles
    latitude_range = 0.014 # let's give about a mile range
    
    # a degree of longitude is ~69 miles at the equator
    # a degree of longitude is ~49 miles at 45 degrees latitude
    # a degree of longitude is 0 miles at 0 degress latitude
    longitude_range = 0.02 # let's give about a mile range at 45 degrees lat
    
    # hours * minutes * seconds
    time_range = 6 * 60 * 60
    
    # create the sql for the select
    # we create a "score" for each social set based on how far away, when, and how many friends are at the event
    sql_select = "SELECT *, "
    sql_select += "(1 - #{latitude_range} * ABS(s.latitude - :latitude)) + " # a max of 1 point for latitude difference 
    sql_select += "(1 - #{longitude_range} * ABS(s.longitude - :longitude)) + " # a max of 1 point for longitude difference
    sql_select += "(1 - ABS(TIMESTAMPDIFF(SECOND, s.time_at, :time_at)) / #{time_range}) + " # a max of 1 point for time difference
    sql_select += "(SELECT  COUNT(*) FROM personal_sets as p, friendships as f "
      sql_select += "WHERE s.id = p.social_set_id AND f.user_id = p.user_id AND f.friend_id = :user_id) " # 1 point for every friend at the event"
    sql_select += "AS score "
    sql_select += "FROM social_sets as s "
    sql_select += "WHERE s.latitude > (:latitude - #{latitude_range}) AND s.latitude < (:latitude + #{latitude_range}) "
    sql_select += "AND s.longitude > (:longitude - #{longitude_range}) AND s.longitude < (:longitude + #{longitude_range}) "
    sql_select += "AND s.time_at > '#{(time_value - time_range).to_s(:db)}' AND s.time_at < '#{(time_value + time_range).to_s(:db)}' "
    sql_select += "ORDER BY score "
    sql_select += "LIMIT :limit "
    
    # search for social sets within the ranges
    self.social_sets = SocialSet.find_by_sql([sql_select, params])
    
  end
end

# SELECT *, (1 - 0.014 * ABS(s.latitude - 37.331689)) +
# (1 - 0.02 * ABS(s.longitude - -122.030731)) +
# (1 - ABS(TIMESTAMPDIFF(SECOND, s.time_at, '2010-05-04 03:11:16')) / (6 * 60 * 60)) +
# (SELECT  COUNT(*) FROM personal_sets as p, friendships as f 
#    WHERE s.id = p.social_set_id AND f.user_id = p.user_id AND f.friend_id = 2)
# as w
# FROM `social_sets` as s
# WHERE s.time_at > '2010-05-03 20:11:16' AND s.time_at < '2010-05-04 08:11:16' 
# AND s.latitude > 37.311689 AND s.latitude < 37.351689 
# AND s.longitude > -122.050731 AND s.longitude < -122.010731


#"latitude"=>"37.331689", "time_at"=>"2010-05-04T02:11:16Z", "longitude"=>"-122.030731"