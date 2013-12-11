class FileattachmentPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(User) && user.is_staff?
        scope.all
      else
        scope.where(:owner_id => user.id)
      end
    end
  end

  def index?
    user.is_any?([:superadmin, :admin, :staff, :organiser])
  end

  def manage?
    super or user.owns(record)
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    super or user.is_any?([:staff, :organiser])
  end

  def download?
    show?
  end
end

