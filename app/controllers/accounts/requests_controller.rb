class Accounts::RequestsController < ApplicationController
  before_filter do
    raise Pundit::NotAuthorizedError if !user_signed_in?
  end

  def index
    @pending_requests = current_user.requests.pending
    @requests = current_user.requests.closed

    respond_to do |format|
      format.html

      # Return all requests in the XML, sorted by creation date
      format.xml {
        render :xml => (@pending_requests + @requests).sort do |a, b|
          a.created_at <=> b.created_at
        end
      }
    end
  end
end
