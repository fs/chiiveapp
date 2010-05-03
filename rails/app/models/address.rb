class Address < ActiveRecord::Base
  
  validates_length_of :full, :maximum => 255
  validates_numericality_of :latitude, :longitude
  
  # #<Geokit::GeoLoc:0x10ec7ec
  #      @city="Essen",
  #      @country_code="DE",
  #      @full_address="Porscheplatz 1, 45127 Essen, Germany",
  #      @lat=51.4578329,
  #      @lng=7.0166848,
  #      @precision="address",
  #      @provider="google",
  #      @state="Nordrhein-Westfalen",
  #      @street_address="Porscheplatz 1",
  #      @success=true,
  #      @zip="45127">
  #     
  
  def format_reverse_geocode(response)
    puts "formatting response, success: #{response.success}"
    puts "response city: #{response.city}"
    self.full = response.full_address
    self.street1 = response.street_address
    self.postal_code = response.zip
    self.city = response.city
    self.state = response.state
    self.country = response.country_code
    self.latitude = response.lat
    self.longitude = response.lng
    self.precision = response.precision
    
    puts "self.city: #{self.city}"
  end
  
end