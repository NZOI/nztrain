class Item < ApplicationRecord
  belongs_to :product
  belongs_to :owner, class_name: Entity
  belongs_to :organisation
  belongs_to :sponsor, class_name: Entity
  belongs_to :donator, class_name: Entity
  belongs_to :holder, class_name: User

  has_many :item_histories

  STATUS = Enumeration.new 0 => :available, 1 => :on_loan

  before_create do
    self.scan_token = SecureRandom.random_number(100000000)
    true
  end

  def scan_token
    sprintf("%08d", self[:scan_token] || 0)
  end

  def loan! holder_id
    begin
      holder = User.find(Integer(holder_id))
    rescue
      return false
    end
    item_histories.create(active: false, action: ItemHistory::ACTION[:loan], holder_id: holder_id, acted_at: DateTime.now)
    self.holder_id = holder_id
    self.status = STATUS[:on_loan]
    save
  end

  def return! holder_id
    begin
      holder = User.find(Integer(holder_id))
    rescue
      return false
    end
    item_histories.create(active: false, action: ItemHistory::ACTION[:return], holder_id: holder_id, acted_at: DateTime.now)
    self.holder_id = holder_id
    self.status = STATUS[:available]
    save
  end
end
