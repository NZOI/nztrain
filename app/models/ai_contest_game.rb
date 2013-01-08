class AiContestGame < ActiveRecord::Base
  belongs_to :ai_contest
  belongs_to :ai_submission_1, :class_name => :AiSubmission
  belongs_to :ai_submission_2, :class_name => :AiSubmission
  

  def judge


  end
end
