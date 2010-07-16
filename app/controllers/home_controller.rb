require 'benchmark'
class HomeController < ApplicationController
  
  japi_connect_login_optional :except => :index_with_login
  
  def index
    force_login = params.delete(:fl)
    if force_login == '1' && current_user.new_record?
      redirect_to :action => :index_with_login
    else
      @story_blocks = current_user.home_blocks
    end
  end
  
  def index_with_login
    redirect_to :action => :index
  end
  
  protected
  
  def after_japi_connect
    bm = Benchmark.measure { 
      @page_data = PageData.new( current_user, :edition => news_edition, :navigation => true, :home => true, :auto_perform => true )
    }
    logger.info( bm.to_s )
    current_user.navigation_links = @page_data.navigation_links
    current_user.home_blocks = @page_data.home_blocks
  end
  
  def set_content_column_count
    @content_column_count = mobile_device? ? 1 : 2
  end
  
end
