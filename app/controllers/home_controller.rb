class HomeController < ApplicationController
  def home
    permission_denied if !user_signed_in?

    @mygroups = current_user.groups

    @group = Group.find(0)
    @problem_set_associations = @group.problem_set_associations

    groups_contests = Contest.joins(:groups => :members).where{(groups.id == 0) | (groups.members.id == my{current_user.id})}.distinct
    @contests = groups_contests.where{(end_time > Time.now)}.order("end_time ASC")

    respond_to do |format|
      format.html
    end
  end
end
