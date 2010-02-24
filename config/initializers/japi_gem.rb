JAPI::PreferenceOption.class_eval do 
  
  def self.cluster_group_options( edition )
    @@cluster_group_options ||= {}
    hash_key = "#{edition.region}_#{edition.locale}"
    section_options = @@cluster_group_options[ hash_key ]
    @@cluster_group_options.delete( hash_key ) if section_options.try( :error )
    @@cluster_group_options[ hash_key ] ||= find( :all, :params => { :preference_id => :homepage_cluster_groups, :region_id => edition.region_id, :language_id => edition.locale_id } )
  end
  
  def self.homepage_display_options
    @@home_display_options ||= nil
    @@home_display_options = nil if @@home_display_options.try( :error )
    @@home_display_options ||= find( :all, :params => { :preference_id => :homepage_boxes } ).freeze
  end
  
  def self.cluster_sort_criteria_options
    @@cluster_sort_criteria_options ||= nil
    @@cluster_sort_criteria_options = nil if @@cluster_sort_criteria_options.try( :error )
    @@cluster_sort_criteria_options ||= sort_criteria_options.dup.delete_if{ |k| k.code.to_s =~ /_clustered$/ }
  end
  
  def self.homepage_display_id( code )
    self.homepage_display_options.select{ |x| x.code == code.to_sym }.collect{ |x| x.id }.first
  end
  
end

JAPI::ClusterGroup.class_eval do
  
  fields :clusters, :stories
  
  def opinions?
    clusters.nil? && stories.is_a?( Array )
  end
  
end

JAPI::Topic.class_eval do
  
  # Last 24 hours
  def home_count( time_span )
    time_span = 24.hours.to_i if time_span.nil? || time_span.to_i > 24.hours.to_i
    result = self.class.find( :one, :params => self.prefix_options.merge( :topic_id => self.id, :time_span => time_span, :per_page => 0 ) )
    #result.facets.count
    result
  end
  
  # used only with home_count
  def name_with_count
    facets.count > 0 ? "#{name} (#{ facets.count })" : name
  end
  
end

JAPI::TopicPreference.class_eval do
  
  attr_accessor :author, :source
  
  def parse_auto_complete_params!( params = {} )
    self.author_id = params[:topic][:author_id] if params[:topic] && params[:topic][:author_id]
    self.source_id = params[:topic][:source_id] if params[:topics] && params[:topic][:source_id]
    self.author = JAPI::Author.new( :name => params[:author][:name] ) if self.author_id && params[:author] && !params[:author][:name].blank?
    self.source = JAPI::Source.new( :name => params[:source][:name] ) if self.source_id && params[:source] && !params[:source][:name].blank?
    self
  end
  
end


JAPI::User.class_eval do
  
  def nav_blocks_order
    @nav_blocks_order ||= home_blocks_order
  end

end

class CASClient::Frameworks::Rails::Filter
  
  
  def self.account_login_url(controller)
    service_url = read_service_url(controller)
    uri = URI.parse(JAPI::Config[:connect][:account_server].to_s + '/login')
    uri.query = "service=#{CGI.escape(service_url)}&jwa=1&locale=#{I18n.locale}"
    log.debug("Generated account login url: #{uri.to_s}")
    return uri.to_s
  end
  
  def self.redirect_to_cas_for_authentication(controller)
    redirect_url = ''
    if use_gatewaying?
      controller.session[:cas_sent_to_gateway] = true
      redirect_url << login_url(controller) << "&gateway=true"
    else
      controller.session[:cas_sent_to_gateway] = false
      redirect_url << account_login_url(controller)
    end
    if controller.session[:previous_redirect_to_cas] &&
        controller.session[:previous_redirect_to_cas] > (Time.now - 1.second)
      log.warn("Previous redirect to the CAS server was less than a second ago. The client at #{controller.request.remote_ip.inspect} may be stuck in a redirection loop!")
      controller.session[:cas_validation_retry_count] ||= 0
      if controller.session[:cas_validation_retry_count] > 3
        log.error("Redirection loop intercepted. Client at #{controller.request.remote_ip.inspect} will be redirected back to login page and forced to renew authentication.")
        redirect_url += "&renew=1&redirection_loop_intercepted=1"
      end
      controller.session[:cas_validation_retry_count] += 1
    else
      controller.session[:cas_validation_retry_count] = 0
    end
    controller.session[:previous_redirect_to_cas] = Time.now
    log.debug("Redirecting to #{redirect_url.inspect}")
    controller.send(:redirect_to, redirect_url)
  end
end


JAPI::Connect::InstanceMethods.class_eval do
  
  # Checks for session validation after 10.minutes
  def session_check_for_validation
    last_st = session.try( :[], :cas_last_valid_ticket )
    unless last_st
      if session[ :cas_user_attrs ]
        session[ :cas_user_attrs ] = nil
        session[ CASClient::Frameworks::Rails::Filter.client.username_session_key ] = nil
      else
        session[:cas_sent_to_gateway] = true if request.referer && URI.parse( request.referer ).host != JAPI::Config[:connect][:account_server].host
      end
      return
    end
    if request.get? && !request.xhr? && ( session[:revalidate].nil? || session[:revalidate] < Time.now.utc )
      session[:cas_last_valid_ticket] = nil
      session[:revalidate] = JAPI::User.session_revalidation_timeout.from_now
    end
  end
  
  def store_referer_location
    session[:return_to] ||= ( params[:referer] || request.referer )
  end
  
  def return_to_uri
    URI.parse( session[:return_to] || "" )
  end
  
  def redirect_back_or_default(default, options = {})
    condition = ( options[:if] ? options[:if].call : true ) rescue true
    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to( condition && !return_to.blank? ? return_to : default )
  end
  
  def uri_path_match?( suri, turi )
    suri = suri.is_a?( URI ) ? suri.dup : URI.parse( suri.to_s )
    suri.query = ''
    turi = turi.is_a?( URI ) ? turi.dup : URI.parse( turi.to_s )
    turi.query = ''
    suri == turi
  end
  
  protected :store_referer_location, :session_check_for_validation, :return_to_uri
  
end

JAPI::Connect::UserAccountsHelper.class_eval do
  
  def url_for_account_server( params = {} )
    if @account_server_prefix_options.nil?
      account_server_uri ||= JAPI::Config[:connect][:account_server]
      @account_server_prefix_options ||= { :host => account_server_uri.host, :port => account_server_uri.port, :protocol => account_server_uri.scheme }
    end
    @account_server_prefix_options.reverse_merge( params.reverse_merge( :locale => locale, :service => self.request.url ) )
  end
  
  def login_path( params = {} )
    url_for_account_server( :controller => 'login', :jwa => 1, :locale => I18n.locale ).reverse_merge( params )
  end
  
  def logout_path( params = {} )
    url_for_account_server( :controller => 'logout' ).reverse_merge( params )
  end
  
end

ApplicationController.class_eval do
  include JAPI::Connect::InstanceMethods
  include JAPI::Connect::UserAccountsHelper
  JAPI::Connect::UserAccountsHelper.instance_methods.each{ |method| self.helper_method( method ) }
end