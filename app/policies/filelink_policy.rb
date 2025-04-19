class FilelinkPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if !user
        scope.none
      elsif user.is_staff?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    show?
  end

  def manage?
    super or user.is_organiser? && (record == FileAttachment || user.owns(record))
  end

  def show?
    return true if user && user.is_staff?
    if policy(record.root).access?
      return true if record.visibility == Filelink::VISIBILITY[:public]
      return (user && !user.competing? && record.visibility == Filelink::VISIBILITY[:protected])
    end
    false
  end

  def create?
    policy(record.root).update? && policy(record.file_attachment).use?
  end

  def update?
    policy(record.root).update? && (record.file_attachment == record.file_attachment.was || policy(record.file_attachment).use?)
  end
end
