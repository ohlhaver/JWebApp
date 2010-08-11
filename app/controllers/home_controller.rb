require 'benchmark'
class HomeController < ApplicationController
  
  japi_connect_login_optional :except => [ :index_with_login ], :skip => [:show ] do
    caches_action :show, :cache_path => Proc.new{ |c| c.send(:action_cache_key) }, :expires_in => 15.minutes
    before_filter :expire_homepage_cache, :if => Proc.new{ |c| c.params['exec'] == '9999' }
    caches_action :index, :cache_path => Proc.new{ |c| c.send(:action_cache_key) }, :expires_in => 5.minutes, :if => Proc.new{ |c| !c.send(:current_user).new_record? && c.send( :flash )[:notice].blank? && c.send(:flash)[:error].blank? }
    caches_action :index, :cache_path => Proc.new{ |c| c.send(:action_cache_key) }, :expires_in => 15.minutes, :if => Proc.new{ |c| c.send(:current_user).new_record? }
  end
  
  def index
    force_login = params.delete(:fl)
    if force_login == '1' && current_user.new_record?
      redirect_to :action => :index_with_login
    else
      @story_blocks = current_user.home_blocks
      @rss_url = home_rss_url( :edition => session[:edition], :locale => I18n.locale, :id => current_user.id_or_default )
    end
  end
  
  def show
    set_edition
    set_locale
    params[:id] = nil if params[:id] == 'default'
    @current_user = JAPI::User.new( :id => params[:id] )
    @page_data = PageData.new( current_user, :edition => news_edition, :home => true, :auto_perform => true )
    @story_blocks = @page_data.home_blocks
  end
  
  def index_with_login
    redirect_to :action => :index
  end
  
  protected
  
  def after_japi_connect
    bm = Benchmark.measure { 
      @page_data = PageData.new( current_user, :edition => news_edition, :navigation => get_navigation?, :home => true, :auto_perform => true )
    }
    logger.info( bm.to_s )
    current_user.navigation_links = @page_data.navigation_links
    current_user.home_blocks = @page_data.home_blocks
  end
  
  def get_navigation?
    params[:format] != 'rss'
  end
  
  def set_content_column_count
    @content_column_count = mobile_device? ? 1 : 2
  end
  
  def expire_homepage_cache
    expire_action( action_cache_key )
    return true
  end
  
  def action_cache_key
    if current_user.new_record?
      [ controller_name, action_name, session[:edition], session[:locale], 'v1' ].join('-')
    else
      current_user.set_preference
      [ controller_name, action_name, session[:edition], session[:locale], current_user.id, current_user.preference.updated_at.to_s.hash, 'v1' ].join("-")
    end
  end
  
end
