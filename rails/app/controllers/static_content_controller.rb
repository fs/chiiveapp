class StaticContentController < ApplicationController
  skip_before_filter :authorize
  before_filter :detect_format, :only => [:index]
  before_filter :facebook_redirect, :if => :request_comes_from_facebook?
  
  def iphone
    redirect_to("http://itunes.apple.com/us/app/chiive/id362351244?mt=8")
  end
  
protected
  def detect_format
    if request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(iPhone|iPod)/] && params[:full_site] != "true"
      request.format = :iphone
    end
  end
end