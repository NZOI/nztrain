class ApplicationController < ActionController::Base
  protect_from_forgery

  def check_signed_in
    if !user_signed_in?

      if !request.env["HTTP_REFERER"].blank? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
        redir = :back
      else
        redir = new_user_session_path
      end

      redirect_to(redir, :alert => "You must be signed in to perform this operation")

      return
    end
  end

end
