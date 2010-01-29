class StoriesController < ApplicationController
  
  japi_connect_login_optional
  
  def index
    params_options = { :q => params[:q], :page => params[:page], :per_page => params[:per_page], @filter => 4 }
    params_options[:user_id] = current_user.id unless current_user.new_record?
    params_options[:language_id] = news_edition.language_id if current_user.new_record?
    params_options[:sort_criteria] = sort_criteria
    params_options[:subscription_type] = subscription_type
    @stories = JAPI::Story.find( :all, :params => params_options )
  end

end
