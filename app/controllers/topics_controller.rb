class TopicsController < ApplicationController
  
  japi_connect_login_required
  
  def index
    params_options =  { :topic_id => :my, :user_id => current_user.id }
    @topics = JAPI::Topic.find( :all, :params => params_options )
  end
  
  def show
    @topic_preference = JAPI::TopicPreference.find( params[:id], :params => { :user_id => current_user.id } )
    self.sort_criteria = @topic_preference.sort_criteria if params[:sc].blank?
    self.subscription_type = @topic_preference.subscription_type if params[:st].blank?
    
    params_options = { :topic_id => params[:id], :page => params[:page],
      :per_page => params[:per_page], :user_id => current_user.id, 
      :sort_criteria => sort_criteria, :subscription_type => subscription_type, @filter => 4 }
      
    @topic = JAPI::Topic.find( :one, 
      :params => params_options )
  end

  def new
  end

  def edit
  end

end
