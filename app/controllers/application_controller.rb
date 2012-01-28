class ApplicationController < ActionController::Base
  before_filter :read_settings
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

  def check_signed_in
    if !user_signed_in?
      redirect_to(new_user_session_path, :alert => "Welcome to nztrain. Please log in or sign up to continue.")
    end
  end

  def check_admin
    if !current_user.is_admin
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
end
