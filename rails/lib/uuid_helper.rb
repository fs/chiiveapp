require 'rubygems'
require 'uuidtools'
module UUIDHelper
  def before_validation()
    self.uuid = UUIDTools::UUID.timestamp_create().to_s.upcase if self.uuid.blank?
  end
end