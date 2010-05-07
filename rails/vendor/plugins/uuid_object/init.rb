require File.dirname(__FILE__) + '/lib/uuidobject'
ActiveRecord::Base.send(:include, Chiive::UUIDObject)