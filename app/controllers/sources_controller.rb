class SourcesController < ApplicationController
  
  japi_connect_login_required :except => :show
  
  def show
    @source = JAPI::Source.find( params[:id] )
    @stories = JAPI::Story.find( :all, :params => { :source_id => params[:id] }, :from => :sources )
  end

end
