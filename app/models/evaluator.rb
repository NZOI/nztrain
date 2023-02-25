class Evaluator < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :problems
  belongs_to :owner, :class_name => :User
  belongs_to :language

  validates :name, :presence => true

end
