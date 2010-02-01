class TopicsController < ApplicationController
  
  japi_connect_login_required
  
  def index
    @topics = JAPI::Topic.find( :all, :params => { :topic_id => :my, :page => params[:page], :per_page => params[:per_page], :user_id => current_user.id } )
  end
  
  def show
    @topic = JAPI::Topic.find( :one, 
      :params => { :topic_id => params[:id], :page => params[:page],
        :per_page => params[:per_page], :user_id => current_user.id } )
  end

  def new
  end

  def edit
  end

end
