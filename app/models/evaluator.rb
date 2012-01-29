class Evaluator < ActiveRecord::Base
  has_many :problems

  attr_accessible :name, :description, :source
end
