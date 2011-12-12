class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :is_admin, :brownie_points

  has_many :problems
  has_many :submissions
  has_many :contest_relations
  has_many :contests, :through => :contest_relations

  def get_solved
    solved = []
    Problem.all.each do |prob|
      if prob.get_score(self) == 100
        solved << prob
      end
    end
    return solved
  end

end
