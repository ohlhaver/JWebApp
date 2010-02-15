ActionController::Routing::Routes.draw do |map|
  
  map.about '/about', :controller => :about, :action => :about
  map.imprint '/imprint', :controller => :about, :action => :imprint
  map.feedback '/feedback', :controller => :about, :action => :feedback
  map.privacy '/privacy', :controller => :about, :action => :privacy
  map.help '/help', :controller => :about, :action => :help
  
  map.top_authors '/authors/top', :controller => 'authors', :action => 'top'
  map.my_authors '/authors/my', :controller => 'authors', :action => 'my'
  map.logout '/logout', :controller => 'application', :action => 'logout'
  map.root :controller => 'home', :action => 'index'
  map.resources :sections
  map.resources :clusters
  map.resources :stories, :collection => [ :advanced, :search_results ]
  map.resources :topics
  map.resources :authors, :member => [ :subscribe, :unsubscribe, :rate ]
  map.resources :sources, :member => [ :rate ]
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
