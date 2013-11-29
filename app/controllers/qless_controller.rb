class QlessController < ApplicationController
  layout "application"

  def default
    raise Authorization::AuthorizationError if current_user.nil? || !current_user.is_admin? || !current_user.has_role?(:superadmin)
  end
end
