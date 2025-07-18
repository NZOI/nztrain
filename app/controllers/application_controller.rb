class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pundit

  layout "scaffold"

  protect_from_forgery

  before_action :update_last_seen_at
  before_action :update_contest_checkin
  before_action :read_settings
  before_action :check_su_loss
  before_action :configure_permitted_parameters, if: :devise_controller?

  # helper ApplicationHelper
  # helper ProblemsHelper
  # helper Accounts::RequestsHelper

  def redirect(message)
    redir = if !request.env["HTTP_REFERER"].blank? && (request.env["HTTP_REFERER"] != request.env["REQUEST_URI"])
      :back
    elsif user_signed_in?
      root_path
    else
      new_user_session_path
    end

    redirect_to(redir, alert: message)
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    is_web_browser = request.accepts.include?(:html) # we only redirect to sign in etc. if the client is a web browser
    if is_web_browser && !user_signed_in? # not signed in, prompt to sign in
      redirect_to(new_user_session_path, alert: "Welcome to nztrain. Please log in or sign up to continue.")
    elsif is_web_browser && !current_user.confirmed? # user is unconfirmed
      redirect_to edit_user_registration_path + "/email", notice: "You must confirm your email before using this site. Change your email and/or resend confirmation instructions."
    else
      render "403", status: :forbidden, layout: "scaffold", formats: :html
    end
  end

  def check_su_loss
    if user_signed_in? && in_su? # so that a user losing admin status cannot keep using admin privileges if they su-ed into another admin user
      original_user = User.find(session[:su][0])
      if !UserPolicy.new(original_user, current_user).su?
        session[:su] = nil
        sign_in original_user # kick them back into their actual account
        redirect_to root_url, alert: "You lost your su authorization"
      end
    end
  end

  def read_settings
    @db_settings = {}
    Setting.all.each do |setting|
      @db_settings[setting.key] = setting.value
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :name, :email, :country_code, :school_id, {school_graduation: [:enabled, :month, :year]}, {school: [:name, :country_code]}])

    if user_signed_in? && current_user.can_change_username?
      devise_parameter_sanitizer.permit(:account_update, keys: [:username])
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
