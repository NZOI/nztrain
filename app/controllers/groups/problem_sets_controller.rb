class Groups::ProblemSetsController < ApplicationController
  layout 'group'

  before_filter do
    @group = Group.find(params[:group_id])
  end

  def edit
    authorize @group, :update?
    @problem_set_associations = @group.problem_set_associations
  end

  def update
    authorize @group, :update?
    @problem_set_association = @group.problem_set_associations.find(params[:id])

    if @problem_set_association.update_attributes(group_problem_set_params)
      redirect_to edit_group_problem_sets_path(@group), :notice => "Problem set association updated."
    else
      redirect_to edit_group_problem_sets_path(@group), :alert => "Association not updated."
    end
  end

  def destroy
    authorize @group, :update?
    @problem_set_association = @group.problem_set_associations.find(params[:id])

    if @problem_set_association.destroy
      redirect_to edit_group_problem_sets_path(@group), :notice => "Problem set removed from group."
    else
      redirect_to edit_group_problem_sets_path(@group), :alert => "Problem set was not removed."
    end
  end

  private
  def group_problem_set_params
    params.require(:group_problem_set).permit(:name_reset, :name).tap do |attributes|
      attributes[:name_reset] = attributes[:name_reset] == 'true' if attributes.has_key?(:name_reset)
      attributes.delete(:name) if attributes[:name_reset]
    end
  end
end

