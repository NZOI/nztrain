class ProblemSeries
  class ReindexWorker < Base
    def perform
      volumes = job.data['volume_id'] ? [job.data['volume_id']] : 0...(importer.index.size)
      volumes.each do |vid|
        issues = job.data['volume_id'] && job.data['issue_id'] ? [job.data['issue_id']] : 0...(importer.volume(vid)[:contests].size)
        issues.each do |num|
          if !importer.downloaded?(vid, num)
            job.log "Issue #{vid}:#{num} not downloaded, cannot index."
          elsif importer.process(vid, num)
            job.log "Issue #{vid}:#{num} re-indexed."
          else
            job.log "Issue #{vid}:#{num} re-indexing failed."
          end
        end
      end
    end
  end
end
