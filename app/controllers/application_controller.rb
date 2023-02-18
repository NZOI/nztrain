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
  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :check_response_content_type
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
    is_web_browser = request.accepts.include?(:html) # we only redirect to sign in etc. if the client is a web browser
    if is_web_browser && !user_signed_in? # not signed in, prompt to sign in
      redirect_to(new_user_session_path, :alert => "Welcome to nztrain. Please log in or sign up to continue.")
    elsif is_web_browser && !current_user.confirmed? # user is unconfirmed
      redirect_to edit_user_registration_path + '/email', :notice => "You must confirm your email before using this site. Change your email and/or resend confirmation instructions."
    else
      render '403', status: :forbidden, layout: "scaffold", formats: :html
    end
  end

  def content_type=(type)
    if type == "application/xml" && !current_user&.is_admin?
      # the XML endpoints expose information that non-admin users should not have access to
      raise Pundit::NotAuthorizedError
    else
      super
    end
  end

  def check_response_content_type
    # the #content_type= check above to forbid XML runs fairly early (which is good) but it is slightly fragile
    # (e.g. it is bypassed if <code>response.content_type=</code> is called directly)
    # so we also verify the content type of the response after the action completes
    # example content types that we'd like to match: "application/xml", "application/xml; charset=utf-8", "text/xml"
    if !response.content_type.nil? && response.content_type.include?("/xml") && !current_user&.is_admin?
      raise "Assertion failure: content type of response was #{response.content_type.inspect} but XML should be forbidden for non-admins"
    end
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

  def read_settings
    @db_settings = {}
    Setting.all.each do |setting|
      @db_settings[setting.key] = setting.value
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username << :name << :email << :country_code << :school_id << {school_graduation: [:enabled, :month, :year]} << {school: [:name, :country_code]}

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
