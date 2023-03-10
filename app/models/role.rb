class Role < ActiveRecord::Base

  has_and_belongs_to_many :users

  validates :name, :presence => true

  scope :distinct, -> { select("distinct(roles.id), roles.*") }

end
