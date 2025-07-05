class Product < ApplicationRecord
  belongs_to :identifier_type
  has_many :items

  validates :name, presence: true
end
