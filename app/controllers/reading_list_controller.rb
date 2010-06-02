class ReadingListController < ApplicationController
  
  japi_connect_login_required :except => :whats
  
  def whats
    @page_title = "Jurnalo - #{t('reading_list.what.label')}"
  end
  
  def index
    prefs = JAPI::StoryPreference.find( :all, :params => { :user_id => current_user.id, :page => params[:page] || 1 } )
    prefs_hash = prefs.inject({}){ |s,x| s[x.story_id] = x.id; s }
    @stories = JAPI::Story.find( :all, :from => :list, :params => { :story_id => prefs.collect( &:story_id ) } )
    @stories.collect{ |x| x.id = prefs_hash[x.id] }
    @stories.pagination = prefs.pagination
    @page_title = "Jurnalo - #{I18n.t('navigation.top.reading_list')}"
  end
  
  def create
    pref = JAPI::StoryPreference.new( :story_id => params[:id] )
    pref.prefix_options = { :user_id => current_user.id }
    if pref.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Fail'
    end
    redirect_to request.referrer || { :action => :index }
  end
  
  def destroy
    pref = JAPI::StoryPreference.find( params[:id], :params => { :user_id => current_user.id } )
    if pref && pref.destroy
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Fail'
    end
    redirect_to :action => :index
  end

end
