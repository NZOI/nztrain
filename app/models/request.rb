class Request < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :requester, class_name: "User" # entity that initiated request
  belongs_to :subject, polymorphic: true # subject controlled by requester
  # verb # action applying subject to target
  belongs_to :target, polymorphic: true # target controlled by requestee
  belongs_to :requestee, class_name: "User" # entity with primary responsibility/right to accept this request

  STATUS = Enumeration.new 0 => :pending, 1 => :accepted, 2 => :rejected, 3 => :cancelled

  STATUS.each do |key, value|
    scope value, -> { where(status: key) }

    define_method "#{value}?" do
      status == key
    end
  end

  # I would prefer to just use expired and not_expired, but these
  # names are in used below for a slightly different use.
  scope :past_expiry, -> { where("expired_at <= ?", DateTime.now) }
  scope :not_past_expiry, -> { where("expired_at > ?", DateTime.now) }

  # IMO a better name for this would be "pending", but see below
  scope :status_pending, -> { where(status: STATUS[:pending]) }

  # These scopes have weird names.
  # * Pending is redefined a scope defined above.
  # * Expired you wouldn't usually expect to check status
  scope :pending, -> { status_pending.merge(not_past_expiry) }
  scope :expired, -> { status_pending.merge(past_expiry) }

  # TODO(Rails5): Convert to where.not(pending).or(past_expiry)
  scope :closed, -> { where("status != ? OR expired_at <= ?", STATUS[:pending], DateTime.now) }

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
