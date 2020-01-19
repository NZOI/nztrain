class ApplicationController < ActionController::Base

  def forem_user
    current_user
  end
  helper_method :forem_user

  include ApplicationHelper
  include Pundit
  layout "scaffold"

  before_filter :update_last_seen_at
  before_filter :update_contest_checkin
  before_filter :read_settings
  before_filter :check_su_loss
  before_filter :wrong_site
  before_filter :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery

  #helper ApplicationHelper
  #helper ProblemsHelper
  #helper Accounts::RequestsHelper

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

  rescue_from Pundit::NotAuthorizedError do |exception|
    if !user_signed_in? # not signed in, prompt to sign in
      redirect_to(new_user_session_path, :alert => "Welcome to nztrain. Please log in or sign up to continue.")
    elsif !current_user.confirmed? # user is unconfirmed
      redirect_to edit_user_registration_path + '/email', :notice => "You must confirm your email before using this site. Change your email and/or resend confirmation instructions."
    else # user signed in and doesn't have permission
      render '403', :status => :forbidden
    end
  end

  def permission_denied
    raise Pundit::NotAuthorizedError
  end

  def check_su_loss
    if user_signed_in? && in_su? # so that a user losing admin status cannot keep using admin privileges if they su-ed into another admin user
      original_user = User.find(session[:su][0])
      if !UserPolicy.new(original_user, current_user).su?
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

  def wrong_site
  end

  def read_settings
    @db_settings = {}
    Setting.all.each do |setting|
      @db_settings[setting.key] = setting.value
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username << :name << :email << :country_code << :school_id << {school_graduation: [:enabled, :month, :year]} << {school: [:name, :country_code]} << :default_language_id

    if user_signed_in? && current_user.can_change_username?
      devise_parameter_sanitizer.for(:account_update) << :username
    end
  end

  def update_last_seen_at
    if user_signed_in?
      original_user.last_seen_at = DateTime.now
      original_user.save
    end
  end

  def update_contest_checkin
    if user_signed_in?
      original_user.contest_relations.active.absent.each do |relation|
        relation.checked_in = true
        relation.save
      end
    end
  end
end
