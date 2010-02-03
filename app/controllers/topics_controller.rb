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
    @topic = JAPI::TopicPreference.new
  end
  
  def create
    @topic = JAPI::TopicPreference.new( params[:japi_topic_preference] ).tap{ |t| t.prefix_options = { :user_id => current_user.id } }
    if @topic.save
      flash[:notice] = 'Success'
      redirect_to topic_path( @topic )
    else
      flash[:error] = @topic.errors.full_messages.join('\n')
      render :action => :new
    end
  end

  def edit
  end

end
