class Item < ActiveRecord::Base
  belongs_to :product
  belongs_to :owner, :class_name => Entity
  belongs_to :organisation
  belongs_to :sponsor, :class_name => Entity
  belongs_to :donator, :class_name => Entity
  belongs_to :holder, :class_name => Entity

  has_many :item_histories

  before_create do
    scan_token = SecureRandom.random_number(100000000)
  end

  def scan_token
    sprintf("%08d", self[:scan_token] || 0)
  end
end
