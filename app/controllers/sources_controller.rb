class SourcesController < ApplicationController
  
  before_filter :store_referer_location, :only => [ :rate ]
  japi_connect_login_required :except => :show
  
  def show
    @source = JAPI::Source.find( params[:id] ) || JAPI::Source.new( :name => I18n.t( 'source.not.found' ) )
    @source_preference = JAPI::SourcePreference.find( nil, :params => { :source_id => params[:id],  :user_id => current_user.id } ) unless current_user.new_record?
    @source_preference ||= JAPI::SourcePreference.new( :source_id => params[:id], :preference => nil )
    @stories = JAPI::Story.find( :all, :params => { :source_id => params[:id], :category_id => ( @category_id == :all ? nil : @category_id ) }, :from => :sources )
    @categories = JAPI::PreferenceOption.category_options.select{ |opt| @stories.facets.category_count( opt.id ) > 0 }
  end
  
  def rate
    if current_user.out_of_limit?( :sources )
      redirect_to upgrade_path( :id => 2 )
      return
    end
    pref = ( JAPI::SourcePreference.find( nil, :params => { :source_id => params[:id],  :user_id => current_user.id } ) || 
        JAPI::SourcePreference.new( :source_id => params[:id] ) )
    pref.prefix_options = { :user_id => current_user.id }
    pref.preference = ( Integer( params[:rating] || "" ) rescue nil )
    if pref.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Error'
    end
    redirect_back_or_default( :action => :show, :id => params[:id] )
  end
  
end
