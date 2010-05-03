module ApplicationHelper
  def user_name(user)
    if user.facebook_uid
      fb_name(user.facebook_uid, :useyou => false)
    else
      h(user.name)
    end
  end
  
  def custom_will_paginate(collection, options = {})
    html = '<ul id="pagination">'
    
    if collection.current_page > 1
      content = custom_will_paginate_link("&laquo; Previous", collection, collection.current_page - 1, options)
    else
      content = "&laquo; Previous"
    end
    html << '<li class="prev">' + content + '</li>'
    
    collection.total_pages.times do |i|
      page = i + 1
      if page == collection.current_page
        html << '<li class="active">' + page.to_s
      else
        html << '<li>' + custom_will_paginate_link(page, collection, page, options)
      end
      html << '</li>'
    end
    
    if collection.current_page < collection.total_pages
      content = custom_will_paginate_link("Next &raquo;", collection, collection.current_page + 1, options)
    else
      content = "Next &raquo;"
    end
    html << '<li class="next">' + content + '</li>'
    
    html << '</ul>'
    html
  end
  
  def custom_will_paginate_link(content, collection, page, options = {})
    param_name = options[:param] || :page
    url_params = page > 1 ? { param_name => page } : {}
    link_to(content, url_for(url_params))
  end
end
