class SectionsController < ApplicationController
  
  japi_connect_login_required :except => :show
  
  def show
    @section = JAPI::ClusterGroup.find( :one, :params => { 
      :user_id => current_user.id, :page => params[:page], 
      :language_id => news_edition.language_id, :region_id => news_edition.region_id,
      :cluster_group_id => params[:id], :per_page => params[:per_page] } )
  end
  
  def new
  end

end
