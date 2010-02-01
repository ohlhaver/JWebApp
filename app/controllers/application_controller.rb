# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  protect_from_forgery
  
  filter_parameter_logging :password
  
  include JAPI::Connect
  
  before_filter :set_filter_var, :set_category_id_var
  layout 'default'
  
  helper_method :sort_criteria, :subscription_type
  
  #after_filter :log_session_info
  protected
  
  def set_category_id_var
    @category_id = params[:ctid].to_i == 0 ? :all : params[:ctid].to_i
  end
  
  def set_filter_var
    @filter = ( params.keys.select{ |x| ['blog', 'video', 'opinion' ].include?( x ) }.first || 'all' ).to_sym
  end
  
  def sort_criteria
    Integer( params[:sc] || current_user.preference.sort_criteria || '1' ) rescue 1
  end
  
  def subscription_type
    Integer( params[:st] || current_user.preference.subscription_type || '0' ) rescue 0
  end
  
end
