class Setting < ActiveRecord::Base

  validates :key, :presence => true

end
