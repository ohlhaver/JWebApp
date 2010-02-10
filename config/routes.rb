ActionController::Routing::Routes.draw do |map|
  map.top_authors '/authors/top', :controller => 'authors', :action => 'top'
  map.my_authors '/authors/my', :controller => 'authors', :action => 'my'
  map.logout '/logout', :controller => 'application', :action => 'logout'
  map.root :controller => 'home', :action => 'index'
  map.resources :sections
  map.resources :clusters
  map.resources :about, :collection => {:imprint => :get, :privacy => :get, :feedback => :get, :help => :get, :about => :get}
  map.resources :stories, :collection => [ :advanced, :search_results ]
  map.resources :topics
  map.resources :authors, :member => [ :subscribe, :unsubscribe, :rate ]
  map.resources :sources, :member => [ :rate ]
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
