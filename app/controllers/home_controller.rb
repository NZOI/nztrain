class HomeController < ApplicationController
  def home
    permission_denied if !user_signed_in?

    @mygroups = current_user.groups

    @problem_sets = Group.find(0).problem_sets

    respond_to do |format|
      format.html
    end
  end
end
