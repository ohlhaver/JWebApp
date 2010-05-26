class HomeController < ApplicationController
  
  japi_connect_login_optional :except => :index_with_login
  
  def index
    force_login = params.delete(:fl)
    if force_login == '1' && current_user.new_record?
      redirect_to :action => :index_with_login
    else
      @story_blocks = current_user.home_blocks( news_edition )
    end
  end
  
  def index_with_login
    redirect_to :action => :index
  end
  
end
