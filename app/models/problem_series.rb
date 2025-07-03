class ProblemSeries < ApplicationRecord
  def index
    Psych.safe_load(index_yaml || "", [Symbol], %i[name local url issues problem_set_id timestamp tasks testdata solutions results problems problem_id points images tests submission_id model language_id file_attachment_id]) || []
  end

  def index=(index)
    self.index_yaml = Psych.dump(index)
  end

  def importer
    @importer ||= importer_type.constantize.new(self)
  end

  def update_index
    ProblemSeries::UpdateWorker.put(id: id)
  end

  def tag
    "ProblemSeries:#{identifier}"
  end

  def download(vn = nil, num = nil)
    ProblemSeries::DownloadWorker.put(id: id, volume_id: vn, issue_id: num)
  end

  def reindex(vn = nil, num = nil)
    ProblemSeries::ReindexWorker.put(id: id, volume_id: vn, issue_id: num)
  end

  def import(vn = nil, num = nil, pids = nil, disposition: :merge, operations: [])
    ProblemSeries::ImportWorker.put(id: id, volume_id: vn, issue_id: num, problem_ids: pids, disposition: disposition, operations: operations)
  end
end
