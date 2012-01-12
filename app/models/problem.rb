class Problem < ActiveRecord::Base
  has_many :test_cases, :dependent => :destroy
  has_many :submissions, :dependent => :destroy
  has_and_belongs_to_many :contests 
  belongs_to :user
  has_and_belongs_to_many :groups
  
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
    return Submission.find(:all, :conditions => ["created_at between ? and ? and user_id = ? and problem_id = ?", from, to, user, self])
  end

  def can_be_viewed_by(user)
    if user.is_admin
      return true
    end

    if user == self.user
      return true
    end

    #might be painfully slow?
    self.contests.each do |contest|
      if contest.has_current_competitor(user)
        return true
      end
    end
    
    user.contests.each do |contest|
      if contest.is_running?
        return false
      end
    end

    self.groups.each do |g|
      if g.users.include?(user)
        return true
      end
    end

    return false
  end

end
