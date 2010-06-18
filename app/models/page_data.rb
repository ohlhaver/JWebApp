class PageData
  
  attr_reader :multi_curb
  attr_reader :navigation_links
  attr_reader :edition
  attr_reader :home_blocks
  attr_reader :user
  attr_reader :top_stories
  
  def initialize( user, options = {} )
    @multi_curb = Curl::Multi.new
    @multi_curb.pipeline = true
    @user = user
    @edition = ( options[:edition] || JAPI::PreferenceOption.parse_edition( user.edition || 'int-en' ) )
    set_user_preferences do
      JAPI::ClusterGroup.async_find( :one, :multi_curb => multi_curb, :params => { 
        :user_id => user.id, :language_id => edition.language_id, :region_id => edition.region_id,
        :cluster_group_id => 'top', :preview => 1 } ){ |cluster| @top_stories = cluster } if options[:top_stories] && @top_stories.nil?
    end
    set_navigation_links if options[:navigation]
    yield( self ) if block_given?
  end
  
  def user_id
    user.new_record? ? 'default' : user.id
  end
  
  def finalize
    if defined?( SystemTimer )
      count = 0
      begin
        count += 1
        SystemTimer.timeout_after( 5 ) do
          multi_curb.perform
        end
      rescue Timeout::Error 
        retry unless count > 5
      end
    else
      multi_curb.perform
    end
  end
  
  def set_user_preferences( &block )
    count = 0
    while( true)
      count += 1
      JAPI::HomeDisplayPreference.async_find( :all, :multi_curb => multi_curb, :params => { :user_id => user_id } ){ |prefs|
        user.home_blocks_order = prefs.collect{ |pref| pref.element.code }
      } if user.home_blocks_order.nil?
    
      JAPI::Preference.async_find( user_id, :multi_curb => multi_curb ){ |pref|
        user.preference = pref
      } if user.preference.nil?
    
      JAPI::TopicPreference.async_find( :all, :multi_curb => multi_curb, :params => { :user_id => user_id } ){ |prefs|
        user.topic_preferences = prefs
      } if user.topic_preferences.nil?
    
      JAPI::HomeClusterPreference.async_find( :all, :multi_curb => multi_curb, :params => { :user_id => user_id, :region_id => edition.region_id, :language_id => edition.language_id } ){ |prefs|
        user.section_preferences = prefs
      } if user.section_preferences.nil?
      block.call if block #( new_multi_curb ) if block
      self.finalize
      break if count > 2 || ( user.preference && user.home_blocks_order && user.topic_preferences && user.section_preferences )
    end
  end
  
  def set_navigation_links
    @navigation_links = ActiveSupport::OrderedHash.new
    user.nav_blocks_order.each do |pref|
      case( pref ) when :top_stories_cluster_group
        @navigation_links[ :top_stories ] = JAPI::NavigationLink.new( :id => 'top', :name => 'Top Stories', :type => 'cluster_group' )
      when :cluster_groups
        @navigation_links[ :sections ] = user.section_preferences.collect{ |pref| 
          JAPI::NavigationLink.new( :id => pref.cluster_group.id , :name => pref.cluster_group.name , :type => 'cluster_group' )
        }
        @navigation_links[ :add_section ] = JAPI::NavigationLink.new( :name => 'Add Section', :type => 'new_cluster_group', :remote => true )
      when :my_topics
        @navigation_links[ :topics ] = user.topic_preferences.collect{ |pref|
          JAPI::NavigationLink.new( :id => pref.id, :name => pref.name, :translate => false, :type => 'topic' )
        }
        @navigation_links[ :add_topic ] = JAPI::NavigationLink.new( :name => 'Add Topic', :type => 'new_topic', :remote => true )
        @navigation_links[ :my_topics ] = JAPI::NavigationLink.new( :name => 'My Topics', :type => 'my_topics', :remote => true )
        JAPI::Topic.async_home_count_map( multi_curb, user.topic_preferences, { :user_id => user_id }, user.preference.default_time_span ){ |topic|
          @navigation_links[:topics].select{ |l| l.id == topic.id }.each{ |link| link.base = topic }
        } unless user.new_record?
      when :my_authors
        @navigation_links[ :my_authors ] = JAPI::NavigationLink.new( :name => 'My Authors', :type => 'my_authors' ).tap{ |l| l.base = 0 }
        JAPI::Story.async_find( :all, :from => :authors, :multi_curb => multi_curb, :params => { :author_ids => :all, :user_id => user.id, 
          :per_page => 0, :time_span => 24.hours.to_i } 
        ) do | results |
          @navigation_links[ :my_authors ].base = results.facets.try(:count) || 0
        end unless user.new_record?
      end
    end
  end
  
  def set_home_blocks
    @home_blocks = ActiveSupport::OrderedHash.new
    user.home_blocks_order.each do |pref|
      case( pref ) when :top_stories_cluster_group
        @home_blocks[:top_stories] = top_stories
      when :cluster_groups
        @home_blocks[:sections] = ActiveSupport::OrderedHash.new
        top_cluster_ids = top_stories.clusters.collect( &:id )
        user.section_preferences.each do | pref |
          @home_blocks[:sections][pref.cluster_group.id] = nil
          JAPI::ClusterGroup.async_find( :one, :multi_curb => multi_curb, :params => { 
            :user_id => user_id, :language_id => edition.language_id, :region_id => edition.region_id,
            :cluster_group_id => pref.cluster_group.id, :preview => 1, :top_cluster_ids => top_cluster_ids } ) do |cluster|
            @home_blocks[:sections][cluster.id] = cluster
          end
        end
      when :my_authors
        @home_blocks[:my_authors] = []
        JAPI::Story.async_find( :all, :from => :authors, :multi_curb => multi_curb, :params => { :author_ids => :all, :user_id => user.id, :preview => 1, :language_id => edition.language_id } ) do |objects|
          @home_blocks[:my_authors] = objects
        end unless user.new_record?
      when :my_topics
        @home_blocks[:topics] = ActiveSupport::OrderedHash.new
        (user.topic_preferences || []).each do |pref|
          @home_blocks[:topics][ pref.id] = nil
          JAPI::Topic.async_find( :one, :multi_curb => multi_curb, :params => { :topic_id => pref.id, :user_id => user.id, :preview => 1 } ) do | topic |
            @home_blocks[:topics][ topic.id ] = topic
          end
        end unless user.new_record?
      end
    end
  end
  
end