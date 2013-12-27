class ProblemSeries
  class DownloadWorker < Base
    def perform
      volumes = job.data['volume_id'] ? [job.data['volume_id']] : 0...(importer.index.size)
      volumes.each do |vid|
        issues = job.data['volume_id'] && job.data['issue_id'] ? [job.data['issue_id']] : 0...(importer.volume(vid)[:contests].size)
        issues.each do |num|
          if importer.download(job.data['volume_id'], num)
            job.log "Problem data for #{vid}:#{num} downloaded."
          else
            job.log "Problem data for #{vid}:#{num} could not be downloaded."
          end
        end
      end
    end
  end
end
