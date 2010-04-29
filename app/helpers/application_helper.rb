module ApplicationHelper
  def user_name(user)
    if user.facebook_uid
      fb_name(user.facebook_uid, :useyou => false)
    else
      h(user.name)
    end
  end
end
