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
  validates :username, :length => { :in => 2..32 }, :format => { :with => /\A\w(\.?\w)*\z/, :message => "Only letters, numbers, underscores or non-adjacent dots allowed in username" }, :presence => true, :uniqueness => { :case_sensitive => false }
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
  has_many :user_problem_relations, dependent: :destroy
  has_many :groups, :through => :memberships
  has_and_belongs_to_many :roles

  #has_many :group_invitations, :class_name => :Request, :as => :target, :conditions => { :verb => 'invite', :subject_type => 'Group' }
  has_many :requests, -> { where("requestee_id = target_id") }, :class_name => Request, :as => :target
  has_one :entity, :as => :entity

  belongs_to :school, counter_cache: true

  # Scopes

  scope :distinct, -> { select("distinct(users.id), users.*") }
  scope :num_solved, -> { select("users.*, (SELECT COUNT(DISTINCT problem_id) FROM user_problem_relations WHERE user_id = users.id AND ranked_score = 100) as num_solved") }

  def self.find_for_authentication(conditions={})
    self.where("lower(username) = lower(?)", conditions[:email]).limit(1).first ||
    self.where("email = ?", conditions[:email]).limit(1).first
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
  def is_staff?
    self.is_any? [:admin, :superadmin, :staff]
  end
  def is_organiser?
    self.is_any? [:admin, :superadmin, :staff, :organiser]
  end
  def is_any?(roles)
    (self.roles.map(&:name) & roles.map(&:to_s)).any?
  end
  def competing?
    defined?(@competing) ? @competing : @competing = self.contest_relations.active.any?
  end
  def openbook?
    !self.competing?
  end
  def owns(object)
    object.respond_to?(:owner_id) and object.owner_id == self.id
  end

  def reload(options = nil)
    remove_instance_variable(:@competing) if defined? @competing
    super
  end

  def country_name
    country = ISO3166::Country[country_code || 'NZ']
    country.name
  end

  def school_graduation=(value)
    if value.is_a? Hash
      if value[:enabled] == 'true'
        super(DateTime.new(value[:year].to_i, value[:month].to_i, -1))
      else
        super(nil)
      end
    else
      super
    end
  end

  def school=(value)
    if value.is_a? Hash
      if value[:name] && value[:name] != ""
        school = School.where(name: value[:name], country_code: value[:country_code]).first_or_initialize
        super(school.synonym || school)
      end
    else
      super
    end
  end

end
