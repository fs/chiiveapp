# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

   JSON_ESCAPE_MAP = {
      '\\'    => '\\\\',
      '</'    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"' }
  
  def escape_json(json)
    if json
      json.gsub(/(\\|<\/|\r\n|[\n\r"])/) { JSON_ESCAPE_MAP[$1] }
    else
      ''
    end
  end
  
  # Edit in place functionality
  def link_for_edit_in_place(path, model_name, attribute, options)
    name = options.delete(:name) || 'edit'
    read_data = options.delete(:read_data) || false
    options[:class] += ' trigger' if options[:class]
    options[:class] = 'trigger' unless options[:class]
    options[:id] = "eip_#{model_name.underscore}-#{options[:id]}-#{attribute}_trigger"
    path_options = {:attribute => attribute}
    path_options.update(:read_data => true) if read_data
    path += "?" + path_options.collect{|k,v| k.to_s + "=" + v.to_s}.join("&")
    link_to name, path, options
  end
  
  # Map marker creation  
  #def create_post_map_marker(social_set, post)
  def create_post_map_marker(post)
    marker = "{\"post_id\": \"#{post.id ? post.id : 'new'}\","
    marker << "\"personal_set_id\": \"#{post.personal_set ? post.personal_set.id : 'new'}\","
    marker << "\"social_set_id\": \"#{post.social_set ? post.social_set.id : 'new'}\","
    marker << "\"marker_type\": \"#{post.social_set ? (post.user == post.social_set.default_user ? '' : 'friend') : ''}\","
    marker << "\"lat\": \"#{post.latitude}\","
    marker << "\"lng\": \"#{post.longitude}\","
    marker << "\"title\": \"#{post.pretty_title}\","
    marker << "\"draggable\": #{current_user and post.user_id == current_user.id}}"
  end

  ################################
  # Map marker creation  
  def create_personal_set_center_map_marker(personal_set)
    return "" unless personal_set
    
    marker = "{\"metrics_id\": \"#{personal_set.id ? personal_set.id : 'new'}\","
    marker << "\"personal_set_id\": \"#{personal_set.id ? personal_set.id : 'new'}\","
    marker << "\"marker_type\": \"ps_center\","
    
    marker << "\"lat\": \"#{personal_set.latitude}\","
    marker << "\"lng\": \"#{personal_set.longitude}\","
    marker << "\"title\": \"#{personal_set.id}\","
    
    marker << "\"cx\": \"#{personal_set.latitude}\","
    marker << "\"cy\": \"#{personal_set.longitude}\","
    marker << "\"ct\": \"#{personal_set.time_at.to_f}\","
    marker << "\"wx\": \"#{personal_set.posts_count}\","
    marker << "\"wy\": \"#{personal_set.posts_count}\","
    marker << "\"wt\": \"#{personal_set.posts_count}\","
    
    marker << "\"draggable\": false}"
  end

  # All PersonalSets Centers
  def create_all_personal_sets_centers_map_markers(user)
    centers = ""
    
    PersonalSet.all.each do |personal_set|
      centers << create_personal_set_center_map_marker(personal_set)
      centers << ','
    end
    
    centers << ''
  end
  #
  ################################

  ################################
  # Map marker creation  
  def create_social_set_center_map_marker(social_set)
    return "" unless social_set
    
    marker = "{\"metrics_id\": \"#{social_set.id ? social_set.id : 'new'}\","
    marker << "\"personal_set_id\": \"#{social_set.id ? social_set.id : 'new'}\","
    marker << "\"marker_type\": \"ss_center\","
    marker << "\"lat\": \"#{social_set.latitude}\","
    marker << "\"lng\": \"#{social_set.longitude}\","
    marker << "\"title\": \"#{social_set.id}\","
    
    marker << "\"cx\": \"#{social_set.latitude}\","
    marker << "\"cy\": \"#{social_set.longitude}\","
    marker << "\"ct\": \"#{social_set.time_at.to_f}\","
    marker << "\"wx\": \"#{social_set.personal_sets_count}\","
    marker << "\"wy\": \"#{social_set.personal_sets_count}\","
    marker << "\"wt\": \"#{social_set.personal_sets_count}\","
    
    marker << "\"draggable\": false}"
  end

  # All PersonalSets Centers
  def create_all_social_sets_centers_map_markers(user)
    centers = ""
    
    SocialSet.all.each do |social_set|
      centers << create_social_set_center_map_marker(social_set)
      centers << ','
    end
    
    centers << ''
  end
  #
  ################################

end
