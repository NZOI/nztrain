class Problem < ActiveRecord::Base
  has_and_belongs_to_many :problem_sets
  has_many :test_cases, :dependent => :destroy
  has_many :submissions, :dependent => :destroy
  belongs_to :user
  belongs_to :evaluator

  attr_accessible :title, :statement, :input, :output, :memory_limit, :time_limit, :evaluator_id

  # Scopes
  scope :distinct, select("distinct(problems.id), problems.*")

  #scope :visible, lambda { joins(:problem_sets => :groups => :users).where( :users => { :id => current_user.id } ).select("distinct(problems.id), problems.*") }
  def self.score_by_user(user_id)
    select("(SELECT MAX(submissions.score) FROM submissions WHERE submissions.problem_id = problems.id AND user_id = #{user_id.to_i}) AS score")
  end
  def self.by_group(group_id)
    joins(:problem_sets => :groups).where(:groups => {:id => group_id}).distinct
  end

  # methods

  def get_highest_scoring_submission(user, from = DateTime.new(1), to = DateTime.now)
    subs = self.submissions.find(:all, :conditions => ["created_at between ? and ? and user_id = ?", from, to, user])
    return subs.max_by {|s| s.score}
  end

  def get_score(user, from = DateTime.new(1), to = DateTime.now)
    subs = self.submissions.find(:all, :limit => 1, :order => "score DESC", :conditions => ["created_at between ? and ? and user_id = ?", from, to, user])
    scores = subs.map {|s| s.score}
    return scores.max 
  end

  def submission_history(user, from = DateTime.new(1), to = DateTime.now)
    return Submission.find(:all, :conditions => ["created_at between ? and ? and user_id IN (?) and problem_id = ?", from, to, user, self], :order => "created_at DESC")
  end

end
