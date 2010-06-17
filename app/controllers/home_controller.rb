class HomeController < ApplicationController
  
  japi_connect_login_optional :except => :index_with_login
  
  def index
    force_login = params.delete(:fl)
    if force_login == '1' && current_user.new_record?
      redirect_to :action => :index_with_login
    else
      @story_blocks = current_user.home_blocks_legacy
    end
  end
  
  def index_with_login
    redirect_to :action => :index
  end
  
  protected
  
  def after_japi_connect
    @page_data = PageData.new( current_user, :edition => news_edition, :top_stories => true, :navigation => true )
    @page_data.set_home_blocks
    @page_data.finalize
    current_user.navigation_links = @page_data.navigation_links
    current_user.home_blocks = @page_data.home_blocks
  end
  
end
