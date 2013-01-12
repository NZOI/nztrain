class AiContest < ActiveRecord::Base

  belongs_to :owner, :class_name => :User

  has_many :submissions, :class_name => :AiSubmission

  def rejudge
    spawn do
      submissions.each do |sub|
        sub.rejudge
      end
    end
  end
  
end
