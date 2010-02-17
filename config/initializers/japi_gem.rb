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