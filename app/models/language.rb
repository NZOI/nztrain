class Language < ActiveRecord::Base
  attr_accessible :compiler, :is_interpreted, :name
end
