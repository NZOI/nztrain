class AiSubmission < ActiveRecord::Base

  belongs_to :ai_contest
  belongs_to :user

  scope :active, where(:active => true)

  def submit
    return false unless activate
    true
  end

  def judge
    ai_contest.submissions.active.each do |submission|
      next if submission.id == self.id
      (0...ai_contest.iterations).each do |iteration|
        game = AiContestGame.where(:ai_contest_id => ai_contest.id, :ai_submission_1_id => self.id, :ai_submission_2_id => submission.id, :iteration => iteration)
        if game.length==0
          game = AiContestGame.create(:ai_contest => ai_contest, :ai_submission_1 => self, :ai_submission_2 => submission, :iteration => iteration)
        else
          game = game.first
        end
        if game.record == nil
          game.judge
          game.save
        end
        game = AiContestGame.where(:ai_contest_id => ai_contest.id, :ai_submission_1_id => submission.id, :ai_submission_2_id => self.id, :iteration => iteration)
        if game.length==0
          game = AiContestGame.create(:ai_contest => ai_contest, :ai_submission_1 => self, :ai_submission_2 => submission, :iteration => iteration)
        else
          game = game.first
        end
        if game.record == nil
          game = AiContestGame.create(:ai_contest => ai_contest, :ai_submission_1 => submission, :ai_submission_2 => self, :iteration => iteration)
          game.judge
          game.save
        end
      end
    end
  end

  def source_file=(file)
    self.source = IO.read(file.path)
  end

  def deactivate
    self.active = false
    save
  end

  def activate
    self.active = true
    return false unless save
    if user_id != ai_contest.owner_id
      AiSubmission.update_all({:active => false}, ["user_id = ? AND ai_contest_id = ? AND id != ?", user, ai_contest_id, id])
    end
    Rails.env == 'test' ? self.judge : spawn { self.judge }
    true
  end

  def rejudge
    #AiContestGame.update_all({:record => nil, :score_1 => nil, :score_2 => nil}, :ai_submission_1_id => id)
    #AiContestGame.update_all({:record => nil, :score_1 => nil, :score_2 => nil}, :ai_submission_2_id => id)
    AiContestGame.delete_all(:ai_submission_1_id => id)
    AiContestGame.delete_all(:ai_submission_2_id => id)
    
    judge if self.active
  end
end
