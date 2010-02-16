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
    @topic = JAPI::TopicPreference.new( params[:japi_topic_preference] || {} )
    if params[:advance] == '1'
      @topic.sort_criteria ||= sort_criteria
      @topic.blog ||= blog_pref
      @topic.video ||= video_pref
      @topic.opinion ||= opinion_pref
      @topic.time_span ||= time_span
      @topic.subscription_type ||= subscription_type
    end
  end
  
  def create
    @topic = JAPI::TopicPreference.new( params[:japi_topic_preference] ).tap do |t| 
      t.prefix_options = { :user_id => current_user.id } 
      t.home_group = true
      t.email_alert = true
    end
    if @topic.save
      flash[:notice] = 'Success'
      redirect_to topic_path( @topic )
    else
      params[:advance] ||= @topic.errors.count > 1 ? '0' : '1'
      flash[:error] = @topic.errors.full_messages.join('\n')
      render :action => :new
    end
  end
  
  def edit
  end
  
  def destroy
    @topic = JAPI::TopicPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { :user_id => current_user.id }
    end
    if @topic.destroy
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :index }
  end
  
  def hide
    @topic = JAPI::TopicPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { :user_id => current_user.id }
      t.home_group = false
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :show, :id => @topic }
  end
  
  def up
    @topic = JAPI::TopicPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { :user_id => current_user.id, :reorder => :up }
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :show, :id => @topic }
  end
  
  def down
    @topic = JAPI::TopicPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { :user_id => current_user.id, :reorder => :down }
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :show, :id => @topic }
  end
  
end
