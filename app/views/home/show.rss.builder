xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do #, 'xmlns:media' => "http://search.yahoo.com/mrss/" do
  xml.channel do
    xml.title "Jurnalo - Home"
    xml.description I18n.t( 'seo.page.default_title' )
    xml.link root_url( :edition => params[:edition] )
    for block_key in @story_blocks.keys
      blocks = @story_blocks[ block_key ]
      blocks.each do |block|
        if block.respond_to?( :clusters ) && !block.clusters.blank?
          for cluster in block.clusters
            story = cluster.stories.first
            xml.item do
              xml.title story.title
              xml.link cluster_url( cluster, :only_path => false )
              xml.pubDate story.created_at.to_s(:rfc822)
              xml.guid cluster_url( cluster, :only_path => false )
              xml.source( story.source.name, :url => story.url )
              xml.category( block_name( block_key, block ) )
              xml.description cluster.top_keywords.join(' - ')
              xml.author( story.authors.first.name ) if story.authors.first
              xml.enclosure( :url => cluster.image, :length => "10240", :type => "image/jpeg", :source => cluster.url ) if cluster.image
              #xml.tag!( "media:content", :url => cluster.image, :medium => "image", :height => "80", :width => "80" ) if cluster.image
              #xml.tag!( "media:copyright", "Image Copyright", :url => cluster.url )  if cluster.image
            end
          end
        end
        if block.respond_to?( :stories ) && !block.stories.blank?
          for story in block.stories
            xml.item do
              xml.title story.title
              xml.link story_url( story, :only_path => false )
              xml.pubDate story.created_at.to_s(:rfc822)
              xml.guid story_url( story, :only_path => false )
              xml.source( story.source.name, :url => story.url )
              xml.category( block_name( block_key, block ) )
              xml.author( story.authors.first.name ) if story.authors.first
              xml.enclosure( :url => story.image, :length => "7063", :type => "image/jpeg" ) if story.image
              #xml.tag!( "media:content", :url => story.image, :medium => "image", :height => "80", :width => "80" ) if story.image
            end
          end
        end
      end
    end
  end
end