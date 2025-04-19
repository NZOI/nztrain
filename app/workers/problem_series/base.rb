class ProblemSeries
  class Base < ApplicationWorker
    def self.inherited(klass)
      klass.default_queue :importer
    end

    def self.put(*args, **options)
      problem_series = ProblemSeries.find(options[:id])
      jid = super
      job = $qless.jobs[jid]
      job.tag(problem_series.tag)
      jid
    end

    def self.perform(job)
      raise "AbstractWorkerError" if instance_of?(ProblemSeries::Base)

      worker = new(job)
      worker.problem_series.with_lock do
        result = worker.perform
      end
      job.complete
    end

    attr_accessor :job, :problem_series, :importer

    def initialize(job)
      self.job = job
      self.problem_series = ProblemSeries.find(job.data["id"])
      self.importer = problem_series.importer
    end
  end
end
