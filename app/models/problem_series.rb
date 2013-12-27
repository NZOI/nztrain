class ProblemSeries < ActiveRecord::Base

  def index
    Psych.safe_load(self.index_yaml || "", [Symbol], %i[name local url contests problem_set_id timestamp tasks testdata solutions results problems problem_id points images tests submission_id model language_id file_attachment_id]) || []
  end

  def index=(index)
    self.index_yaml = Psych.dump(index)
  end

  def importer
    @importer ||= self.importer_type.constantize.new(self)
  end

  def update_index
    ProblemSeries::UpdateWorker.put(id: self.id)
  end

  def tag
    "ProblemSeries:#{self.identifier}"
  end

  def download(vn = nil, num = nil)
    ProblemSeries::DownloadWorker.put(id: self.id, volume_id: vn, issue_id: num)
  end

  def reindex(vn = nil, num = nil)
    ProblemSeries::ReindexWorker.put(id: self.id, volume_id: vn, issue_id: num)
  end

  def import(vn = nil, num = nil, pids = nil, disposition: :merge, operations: [])
    ProblemSeries::ImportWorker.put(id: self.id, volume_id: vn, issue_id: num, problem_ids: pids, disposition: disposition, operations: operations)
  end
end
