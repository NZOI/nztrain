class QlessController < ApplicationController
  layout "application"

  def default
    raise Pundit::NotAuthorizedError if current_user.nil? || !current_user.is_admin?
  end
end
