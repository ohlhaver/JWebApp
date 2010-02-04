JAPI::Model::Base.class_eval do
  
  def self.fields( *args )
    args.each do |method|
     define_method(method) do
       attributes[method]
      end
    end
  end
  
  protected
  
  def update
    prefix_options.symbolize_keys!
    result = client.api_call( self.class.element_update_path, { self.class.element_name.to_sym => self.to_hash, :id => self.to_param }.reverse_merge( prefix_options ) )
    populate_errors( result )
    !result[:error]
  end
  
  def create
    prefix_options.symbolize_keys!
    result = client.api_call( self.class.element_create_path, { self.class.element_name.to_sym => self.to_hash }.reverse_merge( prefix_options ) )
    populate_errors( result )
    attributes[:id] = result[:data] unless result[:error]
    !result[:error]
  end
  
  def populate_errors( result )
    if result[:error]
      errs = Array( { 'attribute' => result[:data], 'type' => result[:message] } )
      errs = Array( result[:data]['error'] || result[:data]['errors'] ) if result[:data].is_a?(Hash)
      errs.each do |err| 
        message = case( err['type'] ) when Symbol:
          I18n.t( "activeresource.errors.models.attribute.#{err['type']}", :raise => true) rescue nil
        when String:
          I18n.t( err['type'], :raise => true) rescue nil
        end
        message ||= err['message'] || err['type']
        errors.add( err['attribute'], message )
      end
    end
  end
  
end

JAPI::PreferenceOption.class_eval do
  
  def self.category_options
    @@category_options ||= nil
    @@category_options = nil if @@category_options.try( :error )
    @@category_options ||= find( :all, :params => { :preference_id => 'category_id' } )
    @@category_options 
  end
  
  def self.time_span_options
    @@time_span_options ||= nil
    @@time_span_options = nil if @@time_span_options.try( :error )
    @@time_span_options ||= find( :all, :params => { :preference_id => 'time_span' } )
    @@time_span_options 
  end
  
  def self.video_pref_options
    @@video_pref_options ||= nil
    @@video_pref_options = nil if @@video_pref_options.try( :error )
    @@video_pref_options ||= find( :all, :params => { :preference_id => 'video' } )
    @@video_pref_options 
  end
  
  def self.opinion_pref_options
    @@opinion_pref_options ||= nil
    @@opinion_pref_options = nil if @@opinion_pref_options.try( :error )
    @@opinion_pref_options ||= find( :all, :params => { :preference_id => 'opinion' } )
    @@opinion_pref_options 
  end
  
  def self.blog_pref_options
    @@blog_pref_options ||= nil
    @@blog_pref_options = nil if @@blog_pref_options.try( :error )
    @@blog_pref_options ||= find( :all, :params => { :preference_id => 'blog' } )
    @@blog_pref_options 
  end
  
end

JAPI::TopicPreference.class_eval do
  
  def self.map
    @@map ||= {
      :search_any => :q,
      :search_all => :qa,
      :search_exact_phrase => :qe,
      :search_except => :qn,
      :sort_criteria => :sc,
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
      params[v] = value if value
    }
    params
  end
  
  # from advance_search -> topic
  def self.extract( params = {} )
    attributes = Hash.new
    map.each{ |k,v|
      attributes[k] = params[k] || params[v]
    }
    return attributes
  end
  
  fields :search_all, :search_any, :search_exact_phrase, :search_except, :sort_criteria, :time_span,
    :category_id, :region_id, :author_id, :source_id, :blog, :video, :opinion, :subscription_type, :name,
    :advanced
  
end