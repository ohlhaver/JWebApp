class StoriesController < ApplicationController
  
  japi_connect_login_optional
  
  def index
    @advanced = false
    @query = params[:q]
    params_options = { :q => params[:q], :page => params[:page], :per_page => params[:per_page], @filter => 4 }
    params_options[:user_id] = current_user.id unless current_user.new_record?
    params_options[:language_id] = news_edition.language_id if current_user.new_record?
    params_options[:sort_criteria] = sort_criteria
    params_options[:subscription_type] = subscription_type
    @stories = JAPI::Story.find( :all, :params => params_options )
  end
  
  def advanced
  end
  
  def search_results
    @advanced = true
    @query =  [ params[:q], params[:qa], params[:qe], params[:qn] ].join(' ')
    JAPI::TopicPreference.normalize!( params )
    params_options = JAPI::TopicPreference.extract( params )
    params_options[:sort_criteria] = sort_criteria
    params_options[:subscription_type] = subscription_type
    params_options.merge!( :page => params[:page], :per_page => params[:per_page] )
    params_options[@filter] == 4 unless @filter == :all
    params_options[:user_id] = current_user.id unless current_user.new_record?
    params_options[:language_id] = news_edition.language_id if current_user.new_record?
    @stories = JAPI::Story.find( :all, :from => :advance, :params => params_options )
    render :action => :index
  end
  
end