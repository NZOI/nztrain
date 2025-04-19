class HomeController < ApplicationController
  def home
    @mygroups = current_user.try(:groups)

    @problem_set_associations = Group.find(0).problem_set_associations

    @contests = policy_scope(Contest).where { (end_time > Time.now) }.order("end_time ASC")

    respond_to do |format|
      format.html
    end
  end
end
