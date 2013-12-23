class RejudgeProblemWorker < ApplicationWorker
  default_queue :queue

  def self.rejudge(problem, queue: nil)
    self.put(id: problem.id, queue: queue)
  end


  def self.perform(job)
    result = self.new(job).perform
    job.complete
  end

  def perform
    self.problem = Problem.find(job.data['id'])

    problem.submissions.each do |submission|
      qjob = $qless.jobs[submission.job] unless submission.job.nil?
      case qjob.try(:state)
      when nil, 'complete'
        submission.rejudge(queue: 'stalejudge')
      when 'running'
        qjob.move('judge')
      when 'waiting','scheduled','stalled' # do nothing
      else
        submission.rejudge(queue: 'stalejudge')
      end
    end
  end

  attr_accessor :problem, :job

  def initialize(job)
    self.job = job
  end
end
