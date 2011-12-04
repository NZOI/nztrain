class ApplicationController < ActionController::Base
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
      redirect("Welcome to nztrain. Please log in or sign up to continue.")
    end
  end

  def check_admin
    if !current_user.is_admin
      redirect("You must be an admin to perform this operation")
    end
  end

end
