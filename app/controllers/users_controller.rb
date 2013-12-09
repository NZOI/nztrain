class UsersController < ApplicationController
  filter_resource_access :member => [], :new => [], :additional_collection => {:online => :inspect, :newest => :index, :suexit => :suexit}

  def index
    @users = User.num_solved.order(:email)
    render
  end

  def online
    @users = User.order(:last_seen_at).reverse_order
    render
  end

  def newest
    @users = User.order(:created_at).reverse_order.limit(100)
    render
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
