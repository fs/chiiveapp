module PersonalSetsHelper
 
  def create_personal_set_map(personal_set, posts)
    map = "<script type=\"text/javascript\"> \n"
    map << "if (mapsVisible == undefined) var mapsVisible = 0;\n"
    map << "var markers#{personal_set.id} = ["
    posts.each do |post|
      map << create_post_map_marker(personal_set, post)
      map << ','
    end
    map << create_personal_set_center_map_marker(personal_set)
    map << ','
    map << "null]; \n"
    map << "if (mapsVisible++ < 0) showMap('map_div#{personal_set.id}', markers#{personal_set.id});\n"
    map << "//maps_containers.push(['map_div#{personal_set.id}', markers#{personal_set.id}]);\n"
    map << "</script> \n"
  end
  
  def create_personal_set_map_container(personal_set)
    container = "<div id=\"map_div#{personal_set.id}\" class=\"map\">"
    container << "<a href=\"#\" class=\"show\""
    container << "onclick=\"showMap('map_div#{personal_set.id}', markers#{personal_set.id}); return false;\">"
    container << "Show Map"
    container << "</a></div>"
  end
  
end
