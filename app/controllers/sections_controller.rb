class SectionsController < ApplicationController
  
  japi_connect_login_required :except => :show
  
  def show
    @section = JAPI::ClusterGroup.find( :one, :params => { 
      :user_id => current_user.id, :page => params[:page], 
      :language_id => news_edition.language_id, :region_id => news_edition.region_id,
      :cluster_group_id => params[:id], :per_page => params[:per_page] } )
  end
  
  def create
    @section = JAPI::HomeClusterPreference.new( :value => params[:preference_id] ).tap do |x| 
      x.prefix_options = { :region_id => news_edition.region_id, :language_id => news_edition.language_id, :user_id => current_user.id }
    end
    if @section.save
      flash[:notice] = 'Section Created Successfully.'
      redirect_to request.referer || { :action => :show, :id => @section.id }
    else
      flash[:error] = 'Error while creating section.'
      redirect_to request.referer || { :action => :index, :controller => :home }
    end
  end
  
  def destroy
    @section = JAPI::HomeClusterPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { 
        :user_id => current_user.id, 
        :region_id => news_edition.region_id, 
        :language_id => news_edition.language_id, 
        :cluster_group_id => params[:id]  }
    end
    if @section.destroy
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :index, :controller => :home }
  end
  
  def hide
    top_stories_id = params[:id] == 'top' ? JAPI::PreferenceOption.homepage_display_id(:top_stories_cluster_group) : -1
    @top_section = JAPI::HomeDisplayPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => top_stories_id
      }
    end
    if @top_section.destroy
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :index, :controller => :home }
  end
  
  def top_section_up
    top_stories_id = JAPI::PreferenceOption.homepage_display_id(:top_stories_cluster_group)
    @top_section = JAPI::HomeDisplayPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => top_stories_id,
        :reorder => :up
      }
    end
    if @top_section.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :index, :controller => :home }
  end
  
  def top_section_down
    top_stories_id = JAPI::PreferenceOption.homepage_display_id(:top_stories_cluster_group)
    @top_section = JAPI::HomeDisplayPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = {
        :user_id => current_user.id,
        :homepage_box_id => top_stories_id,
        :reorder => :down
      }
    end
    if @top_section.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Failure'
    end
    redirect_to request.referer || { :action => :index, :controller => :home }
  end
  
  def up
    return top_section_up if params[:id] == 'top'
    @section = JAPI::HomeClusterPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { 
        :user_id => current_user.id, 
        :reorder => :up,
        :region_id => news_edition.region_id, 
        :language_id => news_edition.language_id, 
        :cluster_group_id => params[:id]
      }
    end
    if @section.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Error'
    end
    redirect_to request.referer || { :action => :show, :id => @section.id }
  end
  
  def down
    return top_section_down if params[:id] == 'top'
    @section = JAPI::HomeClusterPreference.new( :id => params[:id] ).tap do |t|
      t.prefix_options = { 
        :user_id => current_user.id, 
        :reorder => :down,
        :region_id => news_edition.region_id, 
        :language_id => news_edition.language_id, 
        :cluster_group_id => params[:id] 
      }
    end
    if @section.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Error'
    end
    redirect_to request.referer || { :action => :show, :id => @section.id }
  end
  
end
