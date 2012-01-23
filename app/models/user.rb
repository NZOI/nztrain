class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :length => {:maximum => 100}

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :brownie_points

  has_many :problems
  has_many :submissions
  has_many :contest_relations
  has_many :contests, :through => :contest_relations
  # NOTE: difference between groups and roles
  # Groups are used to assign local permissions, eg. access to individual problems/problem sets
  # Roles are used to assign global permissions, eg. access to problems on the whole site
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :roles
  
  def handle
    if !self.name
      return "<#{self.email}>"
    else
      return "#{self.name} <#{self.email}>"
    end
  end

  def get_solved
    solved = []
    @solved_problems = Problem.select("problems.*, (SELECT MAX(score) FROM submissions WHERE problem_id = problems.id AND user_id = #{self.id}) as score")

    @solved_problems.each do |prob|
      if prob.score == 100
        solved << prob
      end
    end
    return solved
  end
  def has_role(role)
    roles.include?(Role.find_by_name(role.to_s))
  end
  def is_superadmin
    self.has_role(:superadmin)
  end
  def is_admin
    self.has_role(:admin) || self.has_role(:superadmin)
  end
end
