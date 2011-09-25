class Problem < ActiveRecord::Base
  has_many :test_cases
  has_many :submissions
  has_and_belongs_to_many :contests 
  belongs_to :user
  has_and_belongs_to_many :groups

  #bit of a hack
  def get_score(user, from = DateTime.new(0), to = DateTime.now)
    subs = self.submissions.find(:all, :conditions => ["created_at between ? and ? and user_id = ?", from, to, user])
    scores = subs.map {|s| s.score}
    return scores.max 
  end

end
