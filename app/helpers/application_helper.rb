# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def edition_options
    [ ['Global', 'int-en'], [ 'Deutschland', 'de-de'], [ 'Schweiz', 'ch-de'], [ 'Österreich', 'at-de' ] ]
  end
  
  def render_cluster_preview( cluster, headline = nil )
    headline ||= cluster.stories.shift
    render :partial => 'clusters/preview', :locals => { :headline => headline, :cluster => cluster }
  end
  
  def render_cluster_info( cluster )
    render :partial => 'clusters/info', :locals => { :cluster => cluster }
  end
  
  def render_story_preview( story )
    render :partial => 'stories/preview', :locals => { :story => story }
  end
  
  def render_story_search_preview( story )
    render :partial => 'stories/search_preview', :locals => { :story => story }
  end
  
  def render_pagination( collection )
    render( :partial => 'shared/pagination', :locals => { :pagination => collection.pagination } ) if collection.pagination.total_pages > 1
  end
  
  def link_to_page( title, page )
    page_url = controller.request.url.gsub(/(\?|\&)page\=\d+&?/){ $1 }
    page_url << "?" unless page_url.match(/\?/)
    page_url << "&" unless page_url.match(/(\?|\&)$/)
    page ? link_to( title, "#{page_url}page=#{page}&") : title
  end
  
  def links_to_keywords( *keywords )
    keywords.collect{ |keyword| link_to( keyword, stories_path( :q => keyword ) ) }
  end
  
  def render_search_preference_form( *attributes )
    render :partial => 'stories/preferences', :locals => { :attributes => attributes }
  end
  
  def preference_options( attribute )
    JAPI::PreferenceOption.send( "#{attribute}_options" ).collect{ |option| [ t(option.name), option.id ] }
  end
  
  def render_filter_links( facets, base_url )
    render :partial => 'shared/filters', :locals => { :facets => facets, :base_url => base_url }
  end
  
  def render_filter_link( filter, name, url, count )
    return unless count > 0
    string = content_tag( :span, '-', :class => 'separator' )
    if @filter == filter
      string << content_tag( :span, t( name, :count => count ) )
    else
      url = url + "&#{filter}=1" unless filter == :all
      string << link_to( t( name, :count => count ), url )
    end
    return string
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
  
  def page_params( options = {} )
    exclude = Array( options[:exclude] ) + ['controller', 'action', 'ticket', 'locale', 'edition']
    params.keys.select{ |x| !exclude.include?( x ) }
  end
  
  def to_param( attribute )
    case attribute when :sort_criteria : :sc
    when :subscription_type : :st
    end
  end
  
end
