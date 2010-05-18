module PostsHelper
  
  def create_post_map(post)
    id = post.id ? post.id : 'new'

    social_sets_centers = post.id ? "" : ","+create_all_social_sets_centers_map_markers(post.user)
    personal_sets_centers = post.id ? "" : ","+create_all_personal_sets_centers_map_markers(post.user)
    
    map = "<script type=\"text/javascript\"> \n"
    map << "var markers_post_#{id} = ["
    map << create_post_map_marker(post)
    map << personal_sets_centers
    map << social_sets_centers
    map << "]; \n"
    map << "showMap('map_div_post#{id}', markers_post_#{id});\n"
    map << "</script> \n"
  end
  
  def create_post_map_container(post)
    id = post.id ? post.id : 'new'
    container = "<div id=\"map_div_post#{id}\" class=\"map\">"
    container << "<a href=\"#\" class=\"show\""
    container << "onclick=\"showMap('map_div_post#{id}', markers_post_#{id}); return false;\">"
    container << "Show Map"
    container << "</a></div>"
  end

end
