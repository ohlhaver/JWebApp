# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include AutoCompleteHelper
  
  def new_login_path( params = {} )
    url_for_account_server( :controller => 'login' ).reverse_merge( params )
  end
  
  def edition_options
    [ ['Global', 'int-en'], [ 'Deutschland', 'de-de'], [ 'Schweiz', 'ch-de'], [ 'Österreich', 'at-de' ] ]
  end
  
  def mouse_over( event_target, &block )
    content = capture do 
      block.call( "mo_#{event_target}_event_src", "mo_#{event_target}" )
    end
    block_called_from_erb?( block ) ? concat( content ) : content
  end
  
  def source_rating_links( source )
    preference_options( :source_rating ).collect{ |option|
      link_to( option.first, rate_source_path( :id => source, :rating => option.last ) )
    }
  end
  
  def author_rating_links( author )
    preference_options( :author_rating ).collect{ |option| 
      link_to( option.first, rate_author_path( :id => author, :rating => option.last ) )
    }
  end
  
  # def mouse_over_menu( &block )
  #    mouse_over_content_tag( block_called_from_erb?(block), 'mo_menu', &block )
  #  end
  #  
  #  def mouse_over_content_tag( concat, class_name, &block )
  #    content = content_tag( :span, :class => "#{class_name}_event_src" ) do
  #      block.call( class_name )
  #    end
  #    concat ? concat( content ) : content
  #  end
  
  def render_cluster_preview( cluster, headline = nil )
    headline ||= cluster.stories.shift
    render :partial => 'clusters/preview', :locals => { :headline => headline, :cluster => cluster }
  end
  
  def render_cluster_info( cluster )
    render :partial => 'clusters/info', :locals => { :cluster => cluster }
  end
  
  def render_story_preview( story, options = nil )
    ( options ||= {} ).reverse_merge( :without => [] )
    options[:without] = Array( options[:without] )
    render :partial => 'stories/preview', :locals => { :story => story, 
      :hide_authors => options[:without].include?( :authors ),
      :hide_add_to_reading_list => options[:without].include?( :add_to_reading_list ) }
  end
  
  def render_headline_preview( story, options = nil )
    ( options ||= {} ).reverse_merge( :without => [] )
    options[:without] = Array( options[:without] )
    render :partial => 'stories/headline_preview', :locals => { :story => story, 
      :hide_authors => options[:without].include?( :authors ),
      :hide_add_to_reading_list => options[:without].include?( :add_to_reading_list ) }
  end
  
  def render_story_search_preview( story )
    render :partial => 'stories/search_preview', :locals => { :story => story }
  end
  
  def render_pagination( collection )
    render( :partial => 'shared/pagination', :locals => { :pagination => collection.pagination } ) if collection.pagination.total_pages > 1
  end
  
  def render_search_pagination( collection, options = {} )
    render( :partial => 'stories/pagination', :locals => options.merge( :pagination => collection.pagination ) ) if collection.pagination.total_pages > 1
  end
  
  def link_to_navigation_item( *args, &block )
    original_args = args.dup
    args.shift if block.nil?
    url_path = url_for( args.first )
    if base_url?( url_path ) then
      content_tag( :span, block ? block.call : original_args.first, :class => 'current' )
    else
      link_to( *original_args, &block )
    end
  end
  
  def link_to_page( title, page )
    page_url = controller.request.url.gsub(/(\?|\&)page\=\d+&?/){ $1 }
    page_url << "?" unless page_url.match(/\?/)
    page_url << "&" unless page_url.match(/(\?|\&)$/)
    page ? link_to( title, "#{page_url}page=#{page}&") : title
  end
  
  def link_to_page_function( title, page )
    page ? link_to_function( title, "pagination_page_click(#{page})" ) : title
  end
  
  def links_to_keywords( *keywords )
    keywords.collect{ |keyword| link_to( keyword, stories_path( :q => keyword ) ) }
  end
  
  def render_search_preference_form( *attributes )
    options = attributes.extract_options!
    render :partial => 'stories/preferences', :locals => options.merge( :attributes => attributes )
  end
  
  def render_cluster_preference_form( *attributes )
    options = attributes.extract_options!
    render :partial => 'clusters/preferences', :locals => options.merge( :attributes => attributes )
  end
  
  def preference_options( attribute, options = {} )
    options[:args] = Array( options[:args] )
    args = [ "#{attribute}_options" ] + options[:args]
    select_options = JAPI::PreferenceOption.send( *args ).collect{ |option| [ t(option.name), option.id ] }
    select_options.unshift( [ '', nil ] ) if options[:include_blank]
    select_options
  end
  
  def render_category_links( categories, base_url )
    render :partial => 'sources/categories', :locals => { :categories => categories, :base_url => base_url }
  end
  
  def render_category_link( name, url, category_id )
    if @category_id == category_id
      content_tag( :span, t( name ) )
    else
      url = url + "?" unless url.match(/\?/)
      url = url + "&ctid=#{category_id}" unless category_id == :all
      link_to( t( name ), url )
    end
  end
  
  def render_filter_links( facets, form_url, form_method )
    render :partial => 'shared/filters', :locals => { :facets => facets, :form_url => form_url, :form_method => form_method }
  end
  
  def render_filter_link( filter, name, count )
    return unless count > 0
    string = ( filter == :all ) ? '' : " "
    if @filter == filter
      string << " " << content_tag( :span, t( name, :count => count ) )
    else
      string << " " << link_to_function( t( name, :count => count ), "filter_click('#{filter}')")
    end
    return string
  end
  
  def render_author_preview( author )
    render :partial => 'authors/preview', :locals => { :author => author }
  end
  
  def render_author_subscription( author_preference, author )
    render :partial => 'authors/subscription', :locals => { :author => author, :author_preference => author_preference }
  end
  
  def render_author_rating_form( author_preference, author )
    render :partial => 'authors/rating_form', :locals => { :author => author, :author_preference => author_preference }
  end
  
  def render_source_rating_form( source_preference, source )
    render :partial => 'sources/rating_form', :locals => { :source => source, :source_preference => source_preference }
  end
  
  def render_my_author_link( name, link_type, url )
    if ( params[:list] == '1' && link_type == :authors ) || ( params[:list] != '1' && link_type == :stories )
      content_tag( :span, t(name) )
    else
      link_to( t(name), url )
    end
  end
  
  def render_author_filter_links( base_url )
    [ :all, :subscribed, :rated ].collect{ |x| render_author_filter_link( x, base_url ) }.join( " " )
  end
  
  def render_author_filter_link( filter, url )
    if @author_filter == filter
      content_tag( :span, t( "author.filter.#{filter}" ) )
    else
      url = url + "&#{filter}=1" unless filter == :all
      link_to( t( "author.filter.#{filter}" ), url )
    end
  end
  
  def display_only_story_search_results?
    controller.action_name != 'index'
  end
  
  def per_page
    Integer( params[:per_page] || ( current_user.per_page rescue 10 ) || 10 )
  end
  
  def per_page_options
    [ 5, 10, 15, 20, 25, 30 ]
  end
  
  def base_url( url = nil )
    url ||= controller.request.url
    url.gsub(/\?.*/, '')
  end
  
  # Matches whether the current request == navigational url
  def base_url?( url_path )
    @base_url ||= base_url.gsub(/http\:\/\/[^\/]+/, '')
    @base_url == url_path
  end
  
  def page_params( options = {} )
    exclude = Array( options[:exclude] ) + ['controller', 'action', 'ticket', 'locale', 'edition', 'id']
    params.keys.select{ |x| !exclude.include?( x ) }
  end
  
  def to_param( attribute )
    case attribute when :sort_criteria : :sc
    when :cluster_sort_criteria : :sc
    when :subscription_type : :st
    end
  end
  
end
