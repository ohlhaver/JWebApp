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
  
  def self.homepage_display_id( code )
    self.homepage_display_options.select{ |x| x.code == code.to_sym }.collect{ |x| x.id }.first
  end
  
end