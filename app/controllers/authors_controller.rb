class AuthorsController < ApplicationController
  
  before_filter :store_referer_location, :only => [ :rate, :subscribe, :unsubscribe, :hide, :up, :down ]
  japi_connect_login_required :except => [ :show, :top ]
  
  before_filter :set_author_filter_var
  
  def show
    @author = JAPI::Author.find( params[:id] ) || JAPI::Author.new( :name => I18n.t( 'author.not.found' ) )
    @author_preference = JAPI::AuthorPreference.find( nil, :params => { :author_id => params[:id],  :user_id => current_user.id } ) unless current_user.new_record?
    @author_preference ||= JAPI::AuthorPreference.new( :author_id => params[:id], :preference => nil, :subscribed => false )
    @stories = JAPI::Story.find( :all, :params => { :author_ids => params[:id] }, :from => :authors )
  end
  
  def top
    render :action => :show
  end
  
  # display list of subscribed author stories
  def my
    return list if params[:list] == '1'
    @stories= JAPI::Story.find( :all, :params => { :author_ids => 'all', :user_id => current_user.id }, :from => :authors)
    render :action => :my_author_stories
  end
  
  # display list of authors
  def list
    params_options = { :page => params[:page] || 1, :per_page => params[:per_page], :user_id => current_user.id }
    params_options[:scope] = :fav if @author_filter == :subscribed
    params_options[:scope] = :pref if @author_filter == :rated
    @author_prefs = JAPI::AuthorPreference.find( :all, :params => params_options )
    render :action => :my_authors
  end
  
  def rate
    pref = ( JAPI::AuthorPreference.find( nil, :params => { :author_id => params[:id],  :user_id => current_user.id } ) || 
        JAPI::AuthorPreference.new( :author_id => params[:id] ) )
    pref.prefix_options = { :user_id => current_user.id }
    pref.preference = ( Integer( params[:rating] || "" ) rescue nil )
    if pref.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Error'
    end
    redirect_back_or_default( :action => :my, :list => 1, :rated => 1 )
  end
  
  def subscribe
    pref = ( JAPI::AuthorPreference.find( nil, :params => { :author_id => params[:id],  :user_id => current_user.id } ) ||
      JAPI::AuthorPreference.new( :author_id => params[:id] ) )
    pref.prefix_options = { :user_id => current_user.id }
    pref.subscribed = true
    if pref.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Error'
    end
    redirect_back_or_default( :action => :my, :list => 1, :subscribed => 1 )
  end
  
  def unsubscribe
    pref = JAPI::AuthorPreference.find( nil, :params => { :author_id => params[:id],  :user_id => current_user.id } )
    pref.subscribed = false if pref
    if pref && pref.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Error'
    end
    redirect_back_or_default( :action => :my, :list => 1, :subscribed => 1 )
  end
  
  # My Authors Hide
  def hide
    my_authors_id = JAPI::PreferenceOption.homepage_display_id(:my_authors)
    @my_authors = JAPI::HomeDisplayPreference.new( :id => my_authors_id ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => my_authors_id
      }
    end
    if @my_authors.destroy
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default( :action => :index, :controller => :home )
  end
  
  # My Authors Up
  def up
    my_authors_id = JAPI::PreferenceOption.homepage_display_id(:my_authors)
    @my_authors = JAPI::HomeDisplayPreference.new( :id => my_authors_id ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => my_authors_id,
        :reorder => :up
      }
    end
    if @my_authors.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default( :action => :index, :controller => :home )
  end
  
  # My Authors Down
  def down
    my_authors_id = JAPI::PreferenceOption.homepage_display_id(:my_authors)
    @my_authors = JAPI::HomeDisplayPreference.new( :id => my_authors_id ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => my_authors_id,
        :reorder => :down
      }
    end
    if @my_authors.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default( :action => :index, :controller => :home )
  end
  
  protected
  
  def set_author_filter_var
    @author_filter = :all 
    @author_filter = :subscribed if params[:subscribed] == '1'
    @author_filter = :rated if params[:rated] == '1'
  end
  
end
