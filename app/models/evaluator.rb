class Evaluator < ActiveRecord::Base
  has_many :problems
  belongs_to :owner, :class_name => :user

  attr_accessible :name, :description, :source
end
