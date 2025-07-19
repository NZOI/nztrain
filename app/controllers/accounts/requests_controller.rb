class Accounts::RequestsController < ApplicationController
  before_action do
    raise Pundit::NotAuthorizedError unless user_signed_in?
  end

  def index
    @pending_requests = current_user.requests.pending
    @requests = current_user.requests.closed
  end
end
