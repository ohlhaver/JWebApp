JAPI::Client.class_eval do
  
  def api_response( path, params )
    url = URI.parse( api_request_url( path ) )
    request = Net::HTTP::Post.new( url.path )
    # Multiple Params Fix
    flatten_params!( params )
    request.set_form_data( params )
    response = Curb.post( url.to_s, request.body, :timeout => 6*(self.timeout||10), :catch_errors => true)
    return response.body_str if response
    return invalid_api_call_response( path )
    # Timeout::timeout( self.timeout ) {
    #   response = Net::HTTP.new( url.host, url.port ).start{ |http| http.request( request ) } rescue nil
    #   return response.try( :body ) || invalid_api_call_response( path )
    # }
    # return timeout_api_call_response( path )
  end
  
end


JAPI::PreferenceOption.class_eval do 
  
  def self.edition_options
    @@edition_options ||= nil
    @@edition_options = nil if @@edition_options.try( :error )
    @@edition_options = find( :all, :params => { :preference_id => 'edition_id' } ).freeze
    @@edition_options
  end

  def self.edition_country_map
    @@edition_country_map ||= nil
    @@edition_country_map = nil if @@edition_country_map.try(:empty?)
    @@edition_country_map ||= self.edition_options.inject( {} ){ |map,record| map[ record.code.to_s.downcase ] = record.id; map }.freeze
  end
  
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
  
  def self.default_country_edition( country_code )
    country_code.try(:downcase!)
    edition_country_map[ country_code ] || 'int-en'
  end
  
end

JAPI::ClusterGroup.class_eval do
  
  fields :clusters, :stories
  
  def opinions?
    clusters.nil? && stories.is_a?( Array )
  end
  
end

JAPI::Cluster.class_eval do
  
  def top_keywords_in_ascii
    top_keywords.collect{ |x| x.to_ascii_s }
  end
  
  def to_param
    "#{id}-#{top_keywords_in_ascii.join('-').gsub(/\.|\ /, '-').gsub(/[^\w\-]/, '')}"
  end
  
end

JAPI::Author.class_eval do
  
  def to_param
    "#{id}-#{name.to_ascii_s.downcase.gsub(/\.|\ /, '-').gsub(/[^\w\-]/, '')}"
  end
  
end

JAPI::Source.class_eval do
  
  def to_param
    "#{id}-#{name.to_ascii_s.downcase.gsub(/\.|\ /, '-').gsub(/\.|\ /, '-').gsub(/[^\w\-]/, '')}"
  end
  
end

JAPI::Story.class_eval do
  
  fields :cluster, :is_opinion, :is_video, :is_blog
  
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
  
  def self.map
    @@map ||= {
      :search_any => :q,
      :search_all => :qa,
      :search_exact_phrase => :qe,
      :search_except => :qn,
      :sort_criteria => :sc,
      :time_span => :ts,
      :subscription_type => :st,
      :blog => :bp,
      :video => :vp,
      :opinion => :op,
      :author_id => :aid,
      :source_id => :sid,
      :category_id => :cid,
      :region_id => :rid
    }
  end
  
  # from topic -> advance_search
  def self.normalize!( params = {})
    map.each{ |k,v|
      value = params.delete( k )
      params[v] = value unless value.blank?
    }
    params
  end
  
  def parse_auto_complete_params!( params = {} )
    self.author_id = params[:topic][:author_id] if params[:topic] && params[:topic][:author_id]
    self.source_id = params[:topic][:source_id] if params[:topics] && params[:topic][:source_id]
    self.author = JAPI::Author.new( :name => params[:author][:name] ) if self.author_id && params[:author] && !params[:author][:name].blank?
    self.source = JAPI::Source.new( :name => params[:source][:name] ) if self.source_id && params[:source] && !params[:source][:name].blank?
    self
  end
  
end

JAPI::Author.class_eval do
  
  def original_name
    attributes[:name]
  end
  
  def name
    join_words( words_array, 4 )
  end
  
  def full_name
    join_words( words_array )
  end
  
  protected
  
  def words_array
    words = original_name.mb_chars.split(' ')
    words.collect{ |w| w[0,1] == '"' ? w[0,1]+w[1..-1].capitalize! : w.capitalize }
  end
  
  def join_words( words, count = nil )
    count && words.size > count ? words[0, count].push('...').join(' ') : words.join(' ')
  end
  
end


JAPI::User.class_eval do
  
  def show_images?
    preference.image == 1
  end
  
  def power_plan?
    preference.plan_id == 1
  end
  
  def out_of_limit?( name )
    preference.out_of_limit
    #klass = JAPI.const_get( name.to_s.singularize.capitalize + 'Preference')
    #!self.power_plan? && klass.find(:all, :params => { :user_id => self.id }).size > 0
  end
  
  def nav_blocks_order
    @nav_blocks_order ||= home_blocks_order
  end
  
  def random_wizard
    if @wizards.blank?
      @wizards = []
      preference.wizards.each{ |key,value| @wizards.push(key) if value == '1' }
    end
    @wizards.rand
  end
  
  def wizard?( wizard_id )
    preference.wizards[ wizard_id.to_s ] == '1'
  end
  
  def turn_off_wizard( wizard_id )
    preference.wizards.merge!( wizard_id.to_s => 0 )
    j = JAPI::Preference.new( :id => self.id, :wizards => { wizard_id => 0 } )
    j.save
  end

end

class CASClient::Frameworks::Rails::Filter
  
  
  def self.account_login_url(controller)
    service_url = read_service_url(controller)
    uri = URI.parse(JAPI::Config[:connect][:account_server].to_s + '/login')
    uri.query = "service=#{CGI.escape(service_url)}&jwa=1"
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
    # unless last_st
    #   if session[ :cas_user_attrs ]
    #     session[ :cas_user_attrs ] = nil
    #     session[ CASClient::Frameworks::Rails::Filter.client.username_session_key ] = nil
    #   else
    #     session[:cas_sent_to_gateway] = true if request.referer && URI.parse( request.referer ).host != JAPI::Config[:connect][:account_server].host
    #   end
    #   return
    # end
    if last_st.nil? && session[ :cas_user_attrs ].nil?
      session[ :cas_sent_to_gateway ] = true if request.referer && URI.parse( request.referer ).host != JAPI::Config[:connect][:account_server].host
      return
    end
    if request.get? && !request.xhr? && ( session[:revalidate].nil? || session[:revalidate] < Time.now.utc )
      session[:cas_last_valid_ticket] = nil
      session[:revalidate] = JAPI::User.session_revalidation_timeout.from_now
    end
  end
  
  def store_referer_location
    request_uri = URI.parse(request.url)
    request_uri.query = nil
    unless session[:request_url] && session[:request_url] == request_uri.to_s
      session[:request_url] = request_uri.to_s
      session[:return_to] = ( params[:referer] || request.referer )
    end
    #log_session_info
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
  
  def set_locale
    params[:locale] = nil if params[:locale].blank? || !JAPI::PreferenceOption.valid_locale?( params[:locale] )
    session[:locale] = params[:locale]
    session[:locale] ||= current_user.locale
    session[:locale] ||= JAPI::PreferenceOption.parse_edition( session[:edition] ).try( :locale ) || 'en'
    I18n.locale = session[:locale]
    params[:locale] = session[:locale] unless params[:locale].blank?
  end
  
  def set_edition
    params[:edition] = session[:edition] if params[:edition].blank? || !JAPI::PreferenceOption.valid_edition?( params[:edition] )
    session[:edition] = params[:edition]
    session[:edition] ||= current_user.edition || JAPI::PreferenceOption.default_country_edition( request.headers['X-GeoIP-Country'] || "" )
    params[:edition] = session[:edition] unless params[:edition].blank?
  end
  
  def restore_mem_cache_cas_last_valid_ticket
    return unless TICKET_STORE
    last_ticket = TICKET_STORE.get( session[:session_id] )
    session[:cas_last_valid_ticket] = last_ticket
  end
  
  def store_to_mem_cache_cas_last_valid_ticket
    return unless TICKET_STORE
    TICKET_STORE.set( session[:session_id], session[:cas_last_valid_ticket], 15.minutes.to_i ) if session[:cas_last_valid_ticket]
    session.delete( :cas_last_valid_ticket )
  end
  
  protected :store_referer_location, :session_check_for_validation, :return_to_uri, :set_edition, :restore_mem_cache_cas_last_valid_ticket, :store_to_mem_cache_cas_last_valid_ticket
  
end

JAPI::Connect::UserAccountsHelper.class_eval do
  
  # def url_for_account_server( params = {} )
  #   if @account_server_prefix_options.nil?
  #     account_server_uri ||= JAPI::Config[:connect][:account_server]
  #     @account_server_prefix_options ||= { :host => account_server_uri.host, :port => account_server_uri.port, :protocol => account_server_uri.scheme }
  #   end
  #   @account_server_prefix_options.reverse_merge( params.reverse_merge( :locale => locale, :service => self.request.url ) )
  # end
  
  def login_path( params = {} )
    url_for_account_server( :controller => 'login', :jwa => 1 ).reverse_merge( params )
  end
  
  def logout_path( params = {} )
    url_for_account_server( :controller => 'logout' ).reverse_merge( params )
  end
  
  def upgrade_required_path( params = {} )
    id = params.delete(:id)
    url_for( account_path( params.merge( :action => :upgrade_required, :jar => 1 ) ) ) + "&id=#{id}"
  end
  
  def fb_login_path( params = {} )
    url_for( url_for_account_server( :controller => 'fb', :action => 'login' ).reverse_merge( params ) )
  end
  
  def url_for_account_server( params = {} )
    if @account_server_prefix_options.nil?
      account_server_uri ||= JAPI::Config[:connect][:account_server]
      @account_server_prefix_options ||= { :host => account_server_uri.host, :port => account_server_uri.port, :protocol => account_server_uri.scheme }
    end
    if params.is_a?( Hash )
      @account_server_prefix_options.reverse_merge( params.reverse_merge( :service => CGI.escape( self.request.url ) ) )
    else
      url_for( @account_server_prefix_options.reverse_merge( :controller => '/' ) ) + params
    end
  end
  
end

JAPI::Connect::ClassMethods.class_eval do
  
  def japi_connect_login_required( options = {} )
    before_filter :restore_mem_cache_cas_last_valid_ticket
    before_filter :session_check_for_validation
    if options[:only]
      before_filter :authenticate_using_cas_with_gateway,    :except => options[:only]
      before_filter :authenticate_using_cas_without_gateway, :only => options[:only]
    elsif options[:except]
      before_filter :authenticate_using_cas_with_gateway, :only => options[:except]
      before_filter :authenticate_using_cas_without_gateway, :except => options[:except]
    else
      before_filter :authenticate_using_cas_without_gateway
    end
    before_filter :store_to_mem_cache_cas_last_valid_ticket
    before_filter :set_current_user
    before_filter :set_edition
    before_filter :set_locale
    before_filter :check_for_new_users, options
    before_filter :redirect_to_activation_page_if_not_active, options
  end
  
  def japi_connect_login_optional( options = {} )
    before_filter :restore_mem_cache_cas_last_valid_ticket
    before_filter :session_check_for_validation
    if options[:only]
      before_filter :authenticate_using_cas_without_gateway,    :except => options[:only]
      before_filter :authenticate_using_cas_with_gateway, :only => options[:only]
    elsif options[:except]
      before_filter :authenticate_using_cas_without_gateway, :only => options[:except]
      before_filter :authenticate_using_cas_with_gateway, :except => options[:except]
    else
      before_filter :authenticate_using_cas_with_gateway
    end
    before_filter :store_to_mem_cache_cas_last_valid_ticket
    before_filter :set_current_user
    before_filter :set_edition
    before_filter :set_locale
    before_filter :check_for_new_users, options
    before_filter :redirect_to_activation_page_if_not_active, options
  end
  
end

ApplicationController.class_eval do
  extend JAPI::Connect::ClassMethods
  include JAPI::Connect::InstanceMethods
  include JAPI::Connect::UserAccountsHelper
  JAPI::Connect::UserAccountsHelper.instance_methods.each{ |method| self.helper_method( method ) }
end