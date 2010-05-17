ActionController::Routing::Routes.draw do |map|
  
  ###########################
  # DOWN FOR MAINTENANCE
  #
  # map.connect ':path.:format', :path => /[^\.]*/, :controller => :down_for_maintenance, :action => 'index'
  #
  # end: DOWN FOR MAINTENANCE
  ###########################

  
  map.resources :invitation_requests

  # routes used for AuthLogic restful authentication
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.facebook 'facebook', :controller => 'user_sessions', :action => 'facebook_proxy'
  map.resource :user_session
  
  # friendships only require create and delete
  map.resources :friendships, :only => [:create, :destroy]
  
  # allow browsing of social sets
  # map.resources :social_sets do |social_sets|
  #   social_sets.resources :comments
  #   social_sets.resources :posts do |posts|
  #     posts.resources :comments
  #   end
  # end
  
  map.resources :social_sets, :as => :events do |social_sets|
    social_sets.resources :comments
    social_sets.resources :posts do |posts|
      posts.resources :comments
    end
  end
  
  # allow post manipulation for iphone and ajax updates
  map.resources :posts do |posts|
    posts.resources :comments
  end
  
  map.resources :comments
  
  # all other post and set requests go through user accounts
  map.resources :users, :collection => [:link_user_accounts] do |users|
    
    users.resources :social_sets, :as => 'events' do |social_sets|
      social_sets.resources :comments
      social_sets.resources :posts do |posts|
        posts.resources :comments
      end
    end
    
    users.resources :posts do |posts|
      posts.resources :comments
    end
    users.resources :friendships, :as => 'friends', :collection => { :find_by_email => :post }
    
    users.resources :social_sets  do |social_sets|
      social_sets.resources :posts do |posts|
        posts.resources :comments
      end
    end
    
    users.resources 'suggested', :controller => 'metrics_manager' , :only => [:create]
  end 
  
  map.resources :password_resets
  
  map.resources :subscribers
  map.get_updates 'stay-in-touch', :controller => 'subscribers', :action => 'new'
  
  map.connect ':action', :controller => 'static_content'
  map.root :controller => :static_content, :action => 'index'
end

