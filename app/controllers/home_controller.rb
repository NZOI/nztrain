class HomeController < ApplicationController
  def home
    @mygroups = current_user.try(:groups)
    @problem_set_associations = Group.find(0).problem_set_associations
    @contests = policy_scope(Contest).not_ended.order("end_time ASC")
  end
end
