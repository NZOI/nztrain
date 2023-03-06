class AiSubmissionsController < ApplicationController
  #filter_resource_access

  # GET /ai_contests/1
  # GET /ai_contests/1.json
  def show
    @ai_contest = @ai_submission.ai_contest
    iteration_limit = @ai_contest.end_time < DateTime.now || (permitted_to? :foresee, @ai_contest) ? @ai_contest.iterations : @ai_contest.iterations_preview
    @ai_contest_games = AiContestGame.where{((ai_submission_1_id == my{@ai_submission.id}) | (ai_submission_2_id == my{@ai_submission.id})) & (iteration < iteration_limit)}
    respond_to do |format|
      format.html# { render :layout => "ai_submission" }
      #format.json { render json: @ai_contest }
    end
  end

  def rejudge
    game_id = request.GET[:game_id]
    game = AiContestGame.find(game_id)
    game.score_1 = nil
    game.score_2 = nil
    game.record = nil
    game.save
    # Rails.env == 'test' ? game.judge : spawn { game.judge } # queue for background processing
    redirect_to ai_submission_path(@ai_submission), :notice => "Submission will be rejudged"
  end

  def deactivate
    @ai_submission.deactivate
    redirect_to submissions_ai_contest_path(@ai_submission.ai_contest_id), :notice => "Submission deactivated"
  end

  def activate
    @ai_submission.activate
    redirect_to submissions_ai_contest_path(@ai_submission.ai_contest_id), :notice => "Submission activated"
  end

  private

    def permitted_params
      @_permitted_params ||= begin
        permitted_attributes = [:name, :start_time, :end_time, :statement, :judge, :sample_ai, :iterations, :iterations_preview]
        permitted_attributes << :owner_id if permitted_to? :transfer, @contest
        params.require(:ai_contest).permit(*permitted_attributes)
      end
    end

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def ai_contest_params
      permitted_params
    end

    def submit_params # attributes allowed to be included in submissions
      @_submit_attributes ||= begin
        submit_attributes = [:language, :source_file]
        submit_attributes << [:source] if permitted_to? :submit_source, @problem
        submit_attributes
      end
      params.require(:ai_submission).permit(*@_submit_attributes).merge(:user_id => current_user.id, :ai_contest_id => params[:id],
        :name => params[:ai_submission][:source_file].original_filename.split('.')[0].humanize )
    end

end
