module FacebookHelper
  def fb_user_name(user)
    if user.facebook_uid
      fb_name(user.facebook_uid, :useyou => false)
    else
      h(user.name)
    end
  end
  
  def fb_user_avatar(user, options = {})
    if user.facebook_uid
      fb_profile_pic(user.facebook_uid, {:size => :square}.merge(options))
    else
      image_tag(user.avatar_image.url(:small), {:width => 50, :height => 50}.merge(options))
    end
  end
  
  def custom_will_paginate(collection, options = {})
    return '' if collection.total_pages <= 1
    
    html = ''
    only_pages = options.delete(:only_pages)
    
    unless only_pages
      if collection.current_page > 1
        content = custom_will_paginate_link("&laquo; Previous", collection, collection.current_page - 1, options)
      else
        content = "&laquo; Previous"
      end
      html << '<li class="prev">' + content + '</li>'
    end
    
    collection.total_pages.times do |i|
      page = i + 1
      if page == collection.current_page
        html << '<li class="active">' + page.to_s
      else
        html << '<li>' + custom_will_paginate_link(page, collection, page, options)
      end
      html << '</li>'
    end
    
    unless only_pages
      if collection.current_page < collection.total_pages
        content = custom_will_paginate_link("Next &raquo;", collection, collection.current_page + 1, options)
      else
        content = "Next &raquo;"
      end
      html << '<li class="next">' + content + '</li>'
    end
    
    options.delete(:param)
    content_tag(:ul, html, {:class => 'pagination'}.merge(options))
  end
  
  def custom_will_paginate_link(content, collection, page, options = {})
    param_name = options[:param] || :page
    link_to(content, url_for(param_name => page))
  end
end
