# Correction for errors in XHR requests to json and xml pages, as used in the iphone app
# Reference: http://groups.google.com/group/rack-devel/browse_thread/thread/4bce411e5a389856
module Mime
  class Type
    def split(*args)
      to_s.split(*args)
    end
  end
end
