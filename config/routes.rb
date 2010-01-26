ActionController::Routing::Routes.draw do |map|
  map.top_authors '/authors/top', :controller => 'authors', :action => 'top'
  map.my_authors '/authors/my', :controller => 'authors', :action => 'my'
  map.logout '/logout', :controller => 'application', :action => 'logout'
  map.root :controller => 'home', :action => 'index'
  map.resources :sections
  map.resources :clusters
  map.resources :stories
  map.resources :topics
  map.resources :authors
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
