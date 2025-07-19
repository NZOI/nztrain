class ContestRelationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_contest_relation

  def destroy
    authorize @contest_relation, :destroy?

    if @contest_relation.destroy
      redirect_to(contestants_contest_path(@contest_relation.contest), notice: "Contestant deleted")
    else
      redirect_to(contestants_contest_path(@contest_relation.contest), alert: "Could not delete contestant")
    end
  end

  def update_year_level
    authorize @contest_relation, :supervise?

    if params[:year_level]
      year_level = params[:year_level].to_i % 15
      @contest_relation.school_year = if year_level != 14
        year_level
      end

      if @contest_relation.save
        redirect_to(contestants_contest_path(@contest_relation.contest), notice: "Contestant year level updated")
        return
      end
    end

    redirect_to(contestants_contest_path(@contest_relation.contest), alert: "Could not update year level of contestant")
  end

  private

  def find_contest_relation
    @contest_relation = ContestRelation.find(params[:id])
  end
end
