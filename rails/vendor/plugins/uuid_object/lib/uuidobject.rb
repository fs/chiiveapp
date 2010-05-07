require 'rubygems'
require 'uuidtools'

module Chiive
  module UUIDObject
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def acts_as_uuidobject
        before_validation :ensure_uuid
        
        def self.find_by_ambiguous_id(id)
          if (id.to_s == id.to_i.to_s)
            self.find_by_id(id)
          else
            self.find_by_uuid(id)
          end
        end
        class_eval <<-EOV
          include Chiive::UUIDObject::InstanceMethods
        EOV
        
      end
    end
    
    module InstanceMethods
      def ensure_uuid
        self.uuid = UUIDTools::UUID.timestamp_create().to_s.upcase if self.uuid.blank?
      end
    end
  end
end