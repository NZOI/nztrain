class ItemHistory < ActiveRecord::Base
  belongs_to :item
  belongs_to :holder, :class_name => User

  # active: is the action active? (set by user borrowing book, or staff accepting return - ie. verifiable action)
  # action: enumeration 
  ACTION = Enumeration.new 0 => :loan, 1 => :return, 2 => :inspect_condition, 3 => :register



end
