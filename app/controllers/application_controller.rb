# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  protect_from_forgery
  
  filter_parameter_logging :password
  
  include JAPI::Connect
  
  before_filter :set_filter_var
  layout 'default'
  
  #after_filter :log_session_info
  protected
  
  def set_filter_var
    @filter = ( params.keys.select{ |x| ['blog', 'video', 'opinion' ].include?( x ) }.first || 'all' ).to_sym
  end
end
