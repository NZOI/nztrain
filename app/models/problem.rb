class Problem < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :problem_sets
  has_many :test_sets, -> { rank(:problem_order) } , :dependent => :destroy
  has_many :prerequisite_sets, -> { where(:prerequisite => true).rank(:problem_order) }, :class_name => TestSet
  has_many :test_cases, -> { rank(:problem_order) }, :dependent => :destroy
  has_many :sample_cases, -> { where(:sample => true).rank(:problem_order) }, :class_name => TestCase
  has_many :submissions, :dependent => :destroy
  belongs_to :owner, :class_name => :User
  belongs_to :evaluator

  has_many :contests, :through => :problem_sets
  has_many :contest_relations, :through => :contests
  has_many :groups, :through => :problem_sets, :uniq => :true
  has_many :group_memberships, :through => :groups, :source => :memberships

  has_many :problem_file_attachments
  has_many :file_attachments, :through => :problem_file_attachments

  validates :title, :presence => true, :uniqueness => { :case_sensitive => false }

  before_save do
    self.input = 'data.in' if self.input == ''
    self.output = 'data.out' if self.output == ''
  end

  # Scopes
  scope :distinct, -> { select("distinct(problems.id), problems.*") }

  scope :score_by_user, ->(user_id) {
    select("problems.*, (SELECT MAX(submissions.score) FROM submissions WHERE submissions.problem_id = problems.id AND submissions.user_id = #{user_id.to_i}) AS score")
  }

  scope :by_group, ->(group_id) { joins(:problem_sets => :groups).where(:groups => {:id => group_id}).distinct }

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
