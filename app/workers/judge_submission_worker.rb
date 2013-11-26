class JudgeSubmissionWorker
  include Sidekiq::Worker
  def perform(submission_id)
    submission = Submission.find(submission_id)
    result = Judge.new(submission).judge

    submission.with_lock do # This block is called within a transaction,
      submission.reload # todo: fetch only columns needed
      submission.judge_log = result.to_json
      submission.isolate_score = result['score']
      submission.judged_at = DateTime.now
      submission.save
    end
  end
end
