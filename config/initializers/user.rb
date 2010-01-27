JAPI::User.class_eval do
  
  def preference
    user_id = new_record? ? 'default' : self.id
    @perference ||= JAPI::Preference.find( :all, :params => { :id => user_id })
  end
  
  def per_page
    preference.per_page
  end
  
end