class ReadingListController < ApplicationController
  
  japi_connect_login_required
  
  def index
    prefs = JAPI::StoryPreference.find( :all, :params => { :user_id => current_user.id } )
    @stories = JAPI::Story.find( :all, :from => :list, :params => { :story_id => prefs.collect( &:story_id ) } )
    @stories.pagination = prefs.pagination
  end

end
