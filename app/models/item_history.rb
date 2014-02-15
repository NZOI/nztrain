class ItemHistory < ActiveRecord::Base
  belongs_to :item
  belongs_to :holder, :class_name => User
end
