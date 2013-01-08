class AiContest < ActiveRecord::Base

  belongs_to :owner, :class_name => :User

  has_many :submissions, :class_name => :AiSubmission

end
