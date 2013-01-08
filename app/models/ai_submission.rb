class AiSubmission < ActiveRecord::Base

  belongs_to :ai_contest
  belongs_to :user

  scope :active, where(:active => true)

  def submit
    self.active = true
    return false unless save
    if user_id != ai_contest.owner_id
      AiSubmission.update_all({:active => false}, ["user = ? AND ai_contest_id = ? AND id != ?", user, ai_contest_id, id])
    end
    Rails.env == 'test' ? self.judge : spawn { self.judge }
    true
  end

  def judge
    ai_contest.submissions.active.each do |submission|
      next if submission.id == self.id
      (0...ai_contest.iterations).each do |iteration|
        game = AiContestGame.new(:ai_contest => ai_contest, :ai_submission_1 => self, :ai_submission_2 => submission, :iteration => iteration)
        game.judge
        game.save
        game = AiContestGame.new(:ai_contest => ai_contest, :ai_submission_1 => submission, :ai_submission_2 => self, :iteration => iteration)
        game.judge
        game.save
      end
    end
  end

  def source_file=(file)
    self.source = IO.read(file.path)
  end
end
