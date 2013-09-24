class ProblemProblemSetController < ApplicationController


  def add
    @problem = Problem.find(params[:problem_id])
    @problem_set = ProblemSet.find(params[:problem][:problem_set_ids])
    permitted_to! :use, @problem
    permitted_to! :update, @problem_set
    # TODO: check for existence of problem and problem set
    @problem_set.problems.push(@problem)

    respond_to do |format|
      format.html { redirect_to(@problem, :notice => 'Problem added to problem set') }
    end
  end

  def remove
    @problem = Problem.find(params[:problem_id])
    @problem_set = ProblemSet.find(params[:problem_set_id])
    permitted_to! :update, @problem_set
    # TODO: check for existence of problem and problem set
    @problem_set.problems.delete(@problem)

    respond_to do |format|
      format.html { redirect_to(edit_problem_set_path(@problem_set), :notice => 'problem removed from problem set') }
    end
  end
end
