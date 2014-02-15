class Item < ActiveRecord::Base
  belongs_to :product
  belongs_to :owner, :class_name => Entity
  belongs_to :organisation
  belongs_to :sponsor, :class_name => Entity
  belongs_to :donator, :class_name => Entity
  belongs_to :holder, :class_name => Entity

  has_many :item_histories
end
