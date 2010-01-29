class StoriesController < ApplicationController
  
  japi_connect_login_optional
  
  def index
    @stories = JAPI::Story.find( :all, :params => { :q => params[:q], :user_id => current_user.id, :page => params[:page], :per_page => params[:per_page], @filter => '1' } )
  end

end
