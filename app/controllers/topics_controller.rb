class TopicsController < ApplicationController
  
  before_filter :store_referer_location, :only => [ :destroy, :unhide, :hide, :up, :down ]
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
    @topic = JAPI::TopicPreference.new( params[:japi_topic_preference] || {} ).parse_auto_complete_params!( params )
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
      t.parse_auto_complete_params!( params )
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
    redirect_back_or_default( { :action => :index }, :if => Proc.new{ !uri_path_match?( request.url, return_to_uri ) } )
  end
  
  def unhide
    @topic = JAPI::TopicPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { :user_id => current_user.id }
      t.home_group = true
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default( :action => :show, :id => @topic )
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
    redirect_back_or_default( :action => :show, :id => @topic )
  end
  
  def up
    return move_up_my_topics if params[:id] == 'my'
    @topic = JAPI::TopicPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { :user_id => current_user.id, :reorder => :up }
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default(:action => :show, :id => @topic )
  end
  
  def down
    return move_down_my_topics if params[:id] == 'my'
    @topic = JAPI::TopicPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { :user_id => current_user.id, :reorder => :down }
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default( :action => :show, :id => @topic )
  end
  
  def move_up_my_topics
    my_topics_id = JAPI::PreferenceOption.homepage_display_id(:my_topics)
    @topic = JAPI::HomeDisplayPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => my_topics_id,
        :reorder => :up
      }
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default( :action => :index )
  end
  
  def move_down_my_topics
    my_topics_id = JAPI::PreferenceOption.homepage_display_id(:my_topics)
    @topic = JAPI::HomeDisplayPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => my_topics_id,
        :reorder => :down
      }
    end
    if @topic.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_back_or_default( :action => :index )
  end
  
end
