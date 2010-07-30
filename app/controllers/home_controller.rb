require 'benchmark'
class HomeController < ApplicationController
  
  japi_connect_login_optional :except => :index_with_login do
    caches_action :index, :cache_path => Proc.new{ |c| c.send(:action_cache_key) }, :expires_in => 5.minutes
  end
  
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
  
  def action_cache_key
    if current_user.new_record?
      [ controller_name, action_name, session[:edition], session[:locale] ].join('-')
    else
      current_user.set_preference
      [ controller_name, action_name, session[:edition], session[:locale], current_user.id, current_user.preference.updated_at.to_s.hash ].join("-")
    end
  end
  
end
