class HomeController < ApplicationController
  
  japi_connect_login_optional
  
  def index
    @story_blocks = current_user.home_blocks( news_edition )
  end
  
end
