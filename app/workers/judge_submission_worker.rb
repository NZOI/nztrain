class JudgeSubmissionWorker
  include Sidekiq::Worker
  def perform(submission_id)
    submission = Submission.find(submission_id)
    Judge.new(submission).judge
  end
end
