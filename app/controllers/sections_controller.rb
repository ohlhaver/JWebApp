class SectionsController < ApplicationController
  
  japi_connect_login_required :except => :show
  
  def show
    @section = JAPI::ClusterGroup.find( :one, :params => { 
      :user_id => current_user.id, :page => params[:page], 
      :language_id => news_edition.language_id, :region_id => news_edition.region_id,
      :cluster_group_id => params[:id], :per_page => params[:per_page] } )
  end
  
  def create
    @section = JAPI::HomeClusterPreference.new( :value => params[:preference_id] ).tap do |x| 
      x.prefix_options = { :region_id => news_edition.region_id, :language_id => news_edition.language_id, :user_id => current_user.id }
    end
    if @section.save
      flash[:notice] = 'Section Created Successfully.'
      redirect_to request.referer || { :action => :show, :id => @section.id }
    else
      flash[:error] = 'Error while creating section.'
      redirect_to request.referer || { :action => :index, :controller => :home }
    end
  end
  
end
