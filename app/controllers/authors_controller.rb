class AuthorsController < ApplicationController
  
  japi_connect_login_required :except => [ :show, :top ]
  
  def show
  end
  
  def top
    render :action => :show
  end
  
  def my
    render :action => :show
  end

end
