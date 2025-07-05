class Setting < ApplicationRecord
  validates :key, presence: true
end
