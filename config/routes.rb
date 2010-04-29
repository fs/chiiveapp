ActionController::Routing::Routes.draw do |map|
  map.resources :photos
  map.root :photos
  map.connect '/', :controller => 'application', :action => 'comments', :conditions => { :method => :post }
end
