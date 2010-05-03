module SocialSetsHelper
 
  def create_social_set_map(social_set)
    map = "<script type=\"text/javascript\"> \n"
    map << "if (mapsVisible == undefined) var mapsVisible = 0;\n"
    map << "var markers#{social_set.id} = ["
    social_set.personal_sets.each do |personal_set|
      map << create_personal_set_center_map_marker(personal_set)
      map << ','
    end
    map << create_social_set_center_map_marker(social_set)
    map << ','
    social_set.posts.each do |post|
      map << create_post_map_marker(post)
      map << ','
    end
    map << "null]; \n"
    map << "if (mapsVisible++ < 0) showMap('map_div#{social_set.id}', markers#{social_set.id});\n"
    map << "//maps_containers.push(['map_div#{social_set.id}', markers#{social_set.id}]);\n"
    map << "</script> \n"
  end
  
  def create_social_set_map_container(social_set)
    container = "<div id=\"map_div#{social_set.id}\" class=\"map\">"
    container << "<a href=\"#\" class=\"show\""
    container << "onclick=\"showMap('map_div#{social_set.id}', markers#{social_set.id}); return false;\">"
    container << "Show Map"
    container << "</a></div>"
  end
  
end
