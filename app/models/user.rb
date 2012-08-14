require 'file_size_validator'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable # unconfirmed users can only log in to change email

  mount_uploader :avatar, AvatarUploader

  validates :name, :length => {:maximum => 100, :minimum => 2}
  validates :username, :length => { :in => 2..32 }, :format => { :with => /\A[a-zA-Z0-9\._]+\z/, :message => "Only letters, numbers, dots or underscores allowed in username" }, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :avatar, :file_size => { :maximum => 40.kilobytes.to_i }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :avatar, :remove_avatar, :avatar_cache

  has_many :problems
  has_many :submissions
  has_many :problem_sets
  has_many :evaluators
  has_many :contest_relations
  has_many :contests, :through => :contest_relations
  # NOTE: difference between groups and roles
  # Groups are used to assign local permissions, eg. access to individual problems/problem sets
  # Roles are used to assign global permissions, eg. access to problems on the whole site
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :roles

  # Scopes
  scope :distinct, select("distinct(users.id), users.*")
  scope :num_solved, select("(SELECT COUNT(DISTINCT submissions.problem_id) FROM submissions JOIN problems ON problems.id = submissions.problem_id WHERE submissions.user_id = users.id AND submissions.score = 100 AND problems.owner_id != users.id) as num_solved")
  
  def self.find_for_authentication(conditions={})
    self.where("lower(username) = lower(?)", conditions[:email]).limit(1).first ||
    self.where("email = ?", conditions[:email]).limit(1).first
  end

  def handle(current_ability = nil)
    if current_ability && (current_ability.can? :inspect, self)
      if self.name && !self.name.empty?
        return "#{self.username} \"#{self.name}\""
      else
        return "#{self.username} <#{self.email}>"
      end
    else
      return "#{self.username}"
    end
  end

  def get_solved
    solved = []
    @solved_problems = Problem.select("problems.*, (SELECT MAX(score) FROM submissions WHERE problem_id = problems.id AND user_id = #{self.id}) as score")

    @solved_problems.each do |prob|
      if prob.score.to_i == 100
        solved << prob
      end
    end
    return solved
  end
  def has_role(role)
    roles.include?(Role.find_by_name(role.to_s))
  end
  def is_superadmin?
    self.has_role(:superadmin)
  end
  def is_admin?
    self.has_role(:admin) || self.has_role(:superadmin)
  end
end
