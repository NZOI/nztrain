class AiContest < ActiveRecord::Base

  belongs_to :owner, :class_name => :User

  has_many :submissions, :class_name => :AiSubmission

  def rejudge
    spawn(:nice => 10) do
      submissions.active.each do |sub|
        sub.rejudge
      end
    end
  end
  
  def prod_judge
    #submissions.each_slice(submissions.length/4).to_a.each do |subs|
    spawn(:nice => 12) do
      submissions.active.each do |sub|
          sub.judge
      end
    end
    #end
  end

  def unjudged_games
    AiContestGame.joins(:ai_submission_1).joins(:ai_submission_2).where(:record => nil, :ai_submission_1=> {:active => true}, :ai_submission_2 => {:active => true}).where(:ai_contest_id => self.id)
  end
end
