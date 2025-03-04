class Evaluator < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :problems
  belongs_to :owner, :class_name => :User
  belongs_to :language

  validates :name, :presence => true
  validates :interactive_processes, :presence => true, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 2 }

end
