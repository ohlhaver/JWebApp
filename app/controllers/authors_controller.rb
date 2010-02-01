class AuthorsController < ApplicationController
  
  japi_connect_login_required :except => [ :show, :top ]
  
  def show
    @author = JAPI::Author.find( params[:id] )
    @stories = JAPI::Story.find( :all, :params => { :author_ids => params[:id] }, :from => :authors )
  end
  
  def top
    render :action => :show
  end
  
  def my
    render :action => :show
  end

end
