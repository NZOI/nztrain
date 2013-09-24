class Problem < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :problem_sets
  has_many :test_sets, :dependent => :destroy
  has_many :test_cases, :through => :test_sets
  has_many :submissions, :dependent => :destroy
  belongs_to :owner, :class_name => :User
  belongs_to :evaluator

  has_many :contests, :through => :problem_sets
  has_many :contest_relations, :through => :contests
  has_many :groups, :through => :problem_sets, :uniq => :true
  has_many :group_members, :through => :groups, :source => :users, :uniq => true

  validates :title, :presence => true, :uniqueness => { :case_sensitive => false }

  before_save do
    self.input = 'data.in' if self.input == ''
    self.output = 'data.out' if self.output == ''
  end

  # Scopes
  scope :distinct, select("distinct(problems.id), problems.*")

  sifter :for_contestant do |u_id|
    id >> Problem.joins(:contest_relations).where{ contest_relations.sift(:is_active) & (contest_relations.user_id == u_id) }
  end
  sifter :for_group_user do |u_id|
    id >> Problem.select(:id).joins(:group_members).where(:users => {:id => u_id})
  end
  sifter :for_everyone do
    id >> Problem.joins(:groups).where(:groups => {:id => 0})
  end

  def self.score_by_user(user_id)
    select("(SELECT MAX(submissions.score) FROM submissions WHERE submissions.problem_id = problems.id AND submissions.user_id = #{user_id.to_i}) AS score")
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
    return Submission.find(:all, :conditions => ["created_at between ? and ? and user_id IN (?) and problem_id = ?", from, to, user, self], :order => "created_at ASC")
  end

  def input_type=(type)
    if type == 'stdin'
      self.input = nil
    elsif type == 'file' && self.input == nil
      self.input = ''
    end
  end

  def input_type
    input.nil? ? 'stdin' : 'file'
  end

  def output_type=(type)
    if type == 'stdout'
      self.output = nil
    elsif type == 'file' && self.output == nil
      self.output = ''
    end
  end

  def output_type
    output.nil? ? 'stdout' : 'file'
  end

end
