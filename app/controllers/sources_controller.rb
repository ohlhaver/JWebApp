class SourcesController < ApplicationController
  
  japi_connect_login_required :except => :show
  
  def show
    @source = JAPI::Source.find( params[:id] ) || JAPI::Source.new( :name => I18n.t( 'source.not.found' ) )
    @stories = JAPI::Story.find( :all, :params => { :source_id => params[:id], :category_id => ( @category_id == :all ? nil : @category_id ) }, :from => :sources )
    @categories = JAPI::PreferenceOption.find( :all, :params => { :preference_id => 'category_id' } )
    unless current_user.new_record?
      # get the source preference for the source
    end
  end

end
