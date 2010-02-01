JAPI::User.class_eval do
  
  def preference
    user_id = new_record? ? 'default' : self.id
    @perference ||= JAPI::Preference.find( user_id )
  end
  
  def per_page
    preference.per_page
  end
  
end

JAPI::FacetCollection.class_eval do
  
  def filter_count
    video_count + blog_count + opinion_count
  end
  
end

JAPI::Cluster.class_eval do
  
  def video_count
    attributes[:video_count] || 0
  end
  
  def blog_count
    attributes[:blog_count] || 0
  end
  
  def opinion_count
    attributes[:opinion_count] || 0
  end
  
  def filter_count
    video_count + blog_count + opinion_count
  end
  
end

JAPI::PaginatedCollection.class_eval do
  
  attr_writer :pagination
  
end

JAPI::PreferenceOption.class_eval do
  
  def language_options
    @@language_options ||= nil
    @@language_options = nil if @@language_options.try( :error )
    @@language_options ||= find( :all, :params => { :preference_id => 'language_id' } )
    @@language_options
  end
  
  def self.sort_criteria_options
    @@sort_criteria_options ||= nil
    @@sort_criteria_options = nil if @@sort_criteria_options.try( :error )
    @@sort_criteria_options ||= find( :all, :params => { :preference_id => 'sort_criteria' } )
    @@sort_criteria_options
  end
  
  def self.subscription_type_options
    @@subscription_type_options ||= nil
    @@subscription_type_options = nil if @@subscription_type_options.try( :error )
    @@subscription_type_options ||= find( :all, :params => { :preference_id => 'subscription_type' } )
    @@subscription_type_options
  end
  
  
end