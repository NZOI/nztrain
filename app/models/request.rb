class Request < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :requester, class_name: :User # entity that initiated request
  belongs_to :subject, polymorphic: true # subject controlled by requester
  # verb # action applying subject to target
  belongs_to :target, polymorphic: true # target controlled by requestee
  belongs_to :requestee, class_name: :User # entity with primary responsibility/right to accept this request

  STATUS = Enumeration.new 0 => :pending, 1 => :accepted, 2 => :rejected, 3 => :cancelled

  STATUS.each do |key, value|
    scope value, -> { where(status: key) }

    define_method "#{value}?" do
      status == key
    end
  end
  scope :pending, -> { where { (status == STATUS[:pending]) & (expired_at > DateTime.now) } }
  scope :expired, -> { where { (status == STATUS[:pending]) & (expired_at <= DateTime.now) } }
  scope :closed, -> { where { (status != STATUS[:pending]) | (expired_at <= DateTime.now) } }

  def pending?
    status == STATUS[:pending] && (expired_at == Float::INFINITY || expired_at > DateTime.now)
  end

  def expired?
    status == STATUS[:pending] && expired_at != Float::INFINITY && expired_at <= DateTime.now
  end

  def accept!
    self.status = STATUS[:accepted]
    save
  end

  def reject!
    self.status = STATUS[:rejected]
    save
  end

  def cancel!
    self.status = STATUS[:cancelled]
    save
  end
end
