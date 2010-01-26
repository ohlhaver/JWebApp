# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def edition_options
    [ ['Global', 'int-en'], [ 'Deutschland', 'de-de'], [ 'Schweiz', 'ch-de'], [ 'Österreich', 'at-de' ] ]
  end
  
  def render_cluster_preview( cluster )
    headline = cluster.stories.shift
    render :partial => 'clusters/preview', :locals => { :headline => headline, :cluster => cluster }
  end
  
  def render_story_preview( story )
    render :partial => 'stories/preview', :locals => { :story => story }
  end
  
  def render_pagination( collection )
    render( :partial => 'shared/pagination', :locals => { :pagination => collection.pagination } ) if collection.pagination.total_pages > 1
  end
  
  def link_to_page( title, page )
    page_url = controller.request.url.gsub(/page\=\d+&?/, "")
    page_url << "?" unless page_url.match(/\?/)
    page_url << "&" unless page_url.match(/(\?|\&)$/)
    page ? link_to( title, "#{page_url}page=#{page}&") : title
  end
  
  def links_to_keywords( *keywords )
    keywords.collect{ |keyword| link_to( keyword, stories_path( :q => keyword ) ) }
  end
  
end
