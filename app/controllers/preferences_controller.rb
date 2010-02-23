class PreferencesController < ApplicationController
  
  before_filter :store_referer_location
  japi_connect_login_required
  
  def set_per_page
    current_user.preference.per_page = params[:id]
    current_user.preference.id = current_user.id
    current_user.preference.save
    redirect_back_or_default( root_path )
  end
  
  protected
  
  def store_referer_location
    session[:return_to] ||= ( params[:referer] || request.referer )
  end
  
end
