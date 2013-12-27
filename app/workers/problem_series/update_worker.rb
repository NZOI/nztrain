class ProblemSeries
  class UpdateWorker < Base

    def perform
      if importer.update
        job.log "Series index updated."
      else
        job.log "Series index update aborted."
      end
    end
  end
end
