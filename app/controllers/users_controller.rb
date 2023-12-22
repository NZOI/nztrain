class UsersController < ApplicationController
  def index
    authorize User.new, :index?
    @users = policy_scope(User).num_solved.order(:email)
    render
  end

  def online
    authorize User.new, :inspect?
    @users = policy_scope(User).order(:last_seen_at).reverse_order
    render
  end

  def newest
    authorize User.new, :index?
    @users = policy_scope(User).order(:created_at).reverse_order.limit(100)
    render
  end

  def suexit
    if (!session[:su]) || session[:su].empty?
      raise Pundit::NotAuthorizedError
    end
    old_user = current_user.username
    sign_in User.find(session[:su].pop)
    redirect_to request.referrer || '/', :notice => "exit su #{old_user}"
  end
end
