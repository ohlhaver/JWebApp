class StoriesController < ApplicationController
  
  japi_connect_login_optional
  
  def index
    @advanced = false
    @query = params[:q]
    params_options = { :q => params[:q] }
    params_options[:sort_criteria] = sort_criteria
    params_options[:subscription_type] = subscription_type
    @topic_params = JAPI::TopicPreference.extract( params_options )
    params_options.merge!( :page => params[:page], :per_page => params[:per_page], @filter => 4 )
    params_options[:user_id] = current_user.id unless current_user.new_record?
    params_options[:language_id] = news_edition.language_id if current_user.new_record?
    @stories = JAPI::Story.find( :all, :params => params_options )
    @authors = JAPI::Author.find( :all, :params => { :q => params[:q], :per_page => 3, :page => 1 } )
    @sources = JAPI::Source.find( :all, :params => { :q => params[:q], :per_page => 3, :page => 1 } )
  end
  
  def advanced
    @topic = JAPI::TopicPreference.new
  end
  
  def search_results
    @advanced = true
    unless params[:japi_topic_preference].blank? && params[:topic_subscription].blank?
      @topic_params = params.delete( :japi_topic_preference )
      @topic_params = params.delete( :topic_subscription ) if @topic_params.blank?
      params.merge!( @topic_params )
    end
    if params[:topic]
      @auto_complete_params = params.delete( :topic )
      params.merge!( @auto_complete_params )
    end
    JAPI::TopicPreference.normalize!( params )
    @query =  [ params[:q], params[:qa], params[:qe], params[:qn] ].select{ |x| !x.blank? }.join(' ')
    params_options = JAPI::TopicPreference.extract( params )
    params_options[:sort_criteria] = sort_criteria
    params_options[:subscription_type] = subscription_type
    @topic_params = params_options.dup
    params_options.merge!( :page => params[:page], :per_page => params[:per_page] )
    params_options[@filter] = 4 unless @filter == :all
    params_options[:user_id] = current_user.id unless current_user.new_record?
    params_options[:language_id] = news_edition.language_id if current_user.new_record?
    @stories = JAPI::Story.find( :all, :from => :advance, :params => params_options )
    render :action => :index
  end
  
end