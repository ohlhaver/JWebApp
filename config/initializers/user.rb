JAPI::User.class_eval do
  
  def preference
    user_id = new_record? ? 'default' : self.id
    @perference ||= JAPI::Preference.find( :all, :params => { :id => user_id })
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