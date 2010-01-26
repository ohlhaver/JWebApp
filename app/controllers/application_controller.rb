# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  protect_from_forgery
  
  filter_parameter_logging :password
  
  include JAPI::Connect
  
  layout 'default'
  
  after_filter :log_session_info
  
end
