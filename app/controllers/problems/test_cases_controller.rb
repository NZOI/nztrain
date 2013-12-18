class Problems::TestCasesController < ApplicationController
  layout 'problem'

  before_filter do
    @problem = Problem.find(params[:problem_id])
  end

  def index
    authorize @problem, :inspect?
    @test_cases = @problem.test_cases
  end

  def update
    authorize @problem, :update?
    flash = ""
    flash_type = :notice
    [:test_cases, :test_sets].each do |type|
      if params[type]
        failed = []
        @problem.send(type).where(:id => params[type].keys).each do |object|
          unless object.update_attributes(send("#{type.to_s.singularize}_params",object.id))
            failed << object
          end
        end
        if failed.empty?
          flash += "#{type.to_s.humanize} updated. "
        else
          flash += "The following #{type.to_s.humanize.downcase} were not updated: #{failed.map(&:name).join(', ')}. "
          flash_type = :alert
        end
      end
    end
    redirect_to problem_test_cases_path(@problem), flash_type => flash
  end

  private

  def test_case_params(id)
    params[:test_cases][id.to_s].permit(:sample, :problem_order_position)
  end

  def test_set_params(id)
    params[:test_sets][id.to_s].permit(:prerequisite, :problem_order_position)
  end
end
