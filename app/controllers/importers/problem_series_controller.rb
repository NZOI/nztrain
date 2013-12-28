class Importers::ProblemSeriesController < ApplicationController
  before_filter do
    raise Pundit::NotAuthorizedError unless current_user.is_superadmin?
    raise ActiveRecord::RecordNotFound if importer.nil?
  end

  def index
    @index = importer.index
  end

  def update_index
    if jid = problem_series.update_index
      redirect_to index_path, :notice => "Index update job (#{jid}) queued."
    else
      redirect_to index_path, :alert => "The series index failed to update."
    end
  end

  def download
    if jid = problem_series.download(params[:vid], params[:cid])
      redirect_to index_path, :notice => "Download job (#{jid}) queued."
    else
      redirect_to index_path, :alert => "Download failed."
    end
  end

  def reindex
    if jid = problem_series.reindex(params[:vid], params[:cid])
      redirect_to index_path, :notice => "Reindex job (#{jid}) queued."
    else
      redirect_to index_path, :alert => "Reindex failed."
    end
  end

  def update
    issue_params = params.require(:issue)
    issue_params = issue_params.require(params[:vid]) if params[:vid]
    issue_params = issue_params.require(params[:cid]) if params[:cid]
    case params[:commit]
    when "Update"
      problem_series.with_lock do
        issue = importer.issue(params[:vid], params[:cid]) or raise ActiveRecord::RecordNotFound
        importer.set_problem_set_id(params[:vid], params[:cid], issue_params[:problem_set_id]) if issue_params[:problem_set_id]

        if issue_params[:problems] && issue_params[:problems].is_a?(Hash)
          issue_params[:problems].each do |pid, new_params|
            importer.set_problem_id(params[:vid], params[:cid], pid, new_params[:problem_id])
          end
        end
        redirect_to index_path, :notice => "Volume/Issue import ids updated"
      end
    when "Import", "Import All"
      operations = issue_params.keys & operation_list
      operations = operation_list if operations.include?('all')

      if issue_params[:checked_problems]
        pids = issue_params[:checked_problems].keys.map{|id|id.to_i} || []
      end
      pids = nil if params[:commit] == "Import All"

      if jid = problem_series.import(params[:vid], params[:cid], pids, disposition: issue_params['disposition'] || 'merge', operations: operations)
        redirect_to index_path, :notice => "Import job (#{jid}) queued."
      else
        redirect_to index_path, :alert => "Import failed."
      end
    else
      redirect_to index_path, :alert => "Unknown operation requested"
    end
  end

  helper_method :series, :importer, :index_path, :problem_series, :operation_list

  protected
  def series
    params[:series]
  end

  def problem_series
    @problem_series ||= ProblemSeries.find_by(identifier: series.to_s)
  end

  def importer
    @importer ||= problem_series.importer
  end

  def index_path
    importers_problem_series_path(series)
  end

  def operation_list
    %w[all statement attributes images test_cases submissions attachments]
  end
end

