class ClustersController < ApplicationController
  
  japi_connect_login_required :except => :show
  
  def show
    @cluster = JAPI::Cluster.find(:one, :params => { 
      :cluster_id => params[:id], :per_page => params[:per_page], 
      :sort_criteria => sort_criteria, :user_id => current_user.id, 
      :page => params[:page], @filter => '1' } ) || JAPI::Cluster.find( :stories => [] )
  end

end
