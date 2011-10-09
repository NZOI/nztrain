class ProblemContestController < ApplicationController
  before_filter :check_admin

  def add
    @problem = Problem.find(params[:problem_id])
    @contest = Contest.find(params[:problem][:contest_ids])

    # TODO: check for existence of problem and contest
    @contest.problems.push(@problem)

    respond_to do |format|
      format.html { redirect_to(@problem, :notice => 'problem added to contest') }
    end
  end

  def remove
    @problem = Problem.find(params[:problem_id])
    @contest = Contest.find(params[:contest_id])

    # TODO: check for existence of problem and contest
    @contest.problems.delete(@problem)

    respond_to do |format|
      format.html { redirect_to(edit_contest_path(@contest), :notice => 'problem removed from contest') }
    end
  end
end
