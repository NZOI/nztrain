class GroupProblemSetController < ApplicationController
  def add
    @problem_set = ProblemSet.find(params[:problem_set_id])
    @group = Group.find(params[:problem_set][:group_ids])
    authorize @problem_set, :use?
    authorize @group, :update?
    # TODO: check for existence of problem and problem set
    @group.problem_sets.push(@problem_set)

    redirect_to(@problem_set, notice: "Problem set added to group")
  end
end
