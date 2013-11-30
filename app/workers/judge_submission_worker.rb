class JudgeSubmissionWorker
  def self.perform(job)
    unless $activerecord_connection
      ActiveRecord::Base.establish_connection
      $activerecord_connection = true # might avoid memory leaks
    end

    self.new.perform(job.data['id'])
    job.complete
  end

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
  rescue StandardError => e
    unless submission.nil?
      submission.reload
      submission.judge_log = {'error' => {'message' => e.message, 'backtrace' => e.backtrace}}.to_json
      submission.save
    end
    #retry if e.is_a?(Errno::ENOMEM)
    raise
  end
end
