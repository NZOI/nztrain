require 'file_size_validator'

class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  # Include devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable # unconfirmed users can only log in to change email

  mount_uploader :avatar, AvatarUploader

  validates :name, :length => {:maximum => 100, :minimum => 2}
  validates :username, :length => { :in => 2..32 }, :format => { :with => /\A[a-zA-Z0-9\._]+\z/, :message => "Only letters, numbers, dots or underscores allowed in username" }, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :avatar, :file_size => { :maximum => 40.kilobytes.to_i }

  before_save do
    self.can_change_username = false if self.username_changed? # can only change username once
    return true
  end

  has_many :problems
  has_many :submissions
  has_many :problem_sets
  has_many :evaluators
  has_many :contest_relations
  # NOTE: difference between groups and roles
  # Groups are used to assign local permissions, eg. access to individual problems/problem sets
  # Roles are used to assign global permissions, eg. access to problems on the whole site
  has_many :memberships, :class_name => :GroupMembership, :foreign_key => :member_id, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_and_belongs_to_many :roles

  #has_many :group_invitations, :class_name => :Request, :as => :subject, :conditions => { :verb => 'invite', :object_type => 'Group' }
  has_many :requests, :class_name => :Request, :as => :subject, :conditions => { :requestee_id => :subject_id }

  # Scopes

  scope :distinct, select("distinct(users.id), users.*")
  scope :num_solved, select("(SELECT COUNT(DISTINCT submissions.problem_id) FROM submissions JOIN problems ON problems.id = submissions.problem_id WHERE submissions.user_id = users.id AND submissions.score = 100 AND problems.owner_id != users.id) as num_solved")
  
  def self.find_for_authentication(conditions={})
    self.where("lower(username) = lower(?)", conditions[:email]).limit(1).first ||
    self.where("email = ?", conditions[:email]).limit(1).first
  end

  def handle
    if permitted_to? :inspect
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
  def has_role?(role)
    self.roles.map(&:name).include?(role.to_s)
  end
  %w{superadmin staff organiser author}.each do |role|
    define_method "is_#{role}?" do
      self.roles.map(&:name).include? role
    end
  end
  def role_symbols
    rolelist = (roles || []).map {|r| r.name.to_sym} << :user << (self.openbook? ? :openbook : :closedbook)
  end
  def is_admin?
    self.is_any? [:admin, :superadmin]
  end
  def is_any?(roles)
    (self.roles.map(&:name) & roles.map(&:to_s)).any?
  end
  def competing?
    ContestRelation.active.user(self.id).any?
  end
  def openbook?
    !self.competing?
  end
end
