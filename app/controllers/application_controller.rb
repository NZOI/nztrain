class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_filter :set_current_user
  before_filter :read_settings
  before_filter :check_su_loss
  before_filter :set_leader
  before_filter :wrong_site
  protect_from_forgery

  def redirect(message)
      if !request.env["HTTP_REFERER"].blank? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
        redir = :back
      elsif user_signed_in?
        redir = root_path
      else
        redir = new_user_session_path
      end

      redirect_to(redir, :alert => message)
  end

  rescue_from CanCan::AccessDenied do |exception|
    if !user_signed_in? # not signed in, prompt to sign in
      #if request.get?
      #  session[:user_return_to] = request.url
      #else
      #  path = ActionController::Routing::Routes.recognize_path(request.url)
      #  if path.has_key? "id"
      #    session[:user_return_to] = url_for :controller => path[:controller], :action => 'show', :id = params[:id]
      #end
      redirect_to(new_user_session_path, :alert => "Welcome to nztrain. Please log in or sign up to continue.")
    elsif !current_user.confirmed? # user is unconfirmed
      redirect_to edit_user_registration_path + '/email', :notice => "You must confirm your email before using this site. Change your email and/or resend confirmation instructions."
    else # user signed in and doesn't have permission
      raise
    end
  end

  def permission_denied
    if !user_signed_in? # not signed in, prompt to sign in
      redirect_to(new_user_session_path, :alert => "Welcome to nztrain. Please log in or sign up to continue.")
    elsif !current_user.confirmed? # user is unconfirmed
      redirect_to edit_user_registration_path + '/email', :notice => "You must confirm your email before using this site. Change your email and/or resend confirmation instructions."
    else # user signed in and doesn't have permission
      raise Authorization::AuthorizationError
    end
  end

  def check_su_loss
    if user_signed_in? && in_su? # so that a user losing admin status cannot keep using admin privileges if they su-ed into another admin user
      original_user = User.find(session[:su][0])
      if Ability.new(original_user).cannot? :su, current_user # lost privileges to su into the user
        session[:su] = nil
        sign_in original_user # kick them back into their actual account
        redirect_to root_url, :alert => "You lost your su authorization"
      end
    end
  end

  def check_admin
    if !current_user.is_admin?
      redirect("You must be an admin to perform this operation")
    end
  end
  
  def set_leader
    @brownie_leader = User.find(:first, :order => "brownie_points DESC")
  end

  def wrong_site
  end

  def read_settings
    @db_settings = {}
    Setting.all.each do |setting|
      @db_settings[setting.key] = setting.value
    end
  end

  protected
  def set_current_user
    Authorization.current_user = current_user
  end
end
