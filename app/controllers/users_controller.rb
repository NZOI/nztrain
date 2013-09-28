class UsersController < ApplicationController
  filter_resource_access :member => [], :new => [], :additional_collection => :suexit

  def index
    @users = User.select('*').num_solved.order(:email)
    respond_to do |format|
      format.html
      format.xml {render :xml => @users }
    end
  end

  def suexit
    if (!session[:su]) || session[:su].empty?
      raise Authorization::AuthorizationError
    end
    old_user = current_user.username
    sign_in User.find(session[:su].pop)
    redirect_to request.referrer, :notice => "exit su #{old_user}"
  end
end
