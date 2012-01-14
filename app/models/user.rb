class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :length => {:maximum => 100}

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :handle, :email, :password, :password_confirmation, :remember_me, :is_admin, :brownie_points

  has_many :problems
  has_many :submissions
  has_many :contest_relations
  has_many :contests, :through => :contest_relations
  
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

end
