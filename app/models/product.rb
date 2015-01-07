class Product < ActiveRecord::Base
  belongs_to :identifier_type
  has_many :items

end
