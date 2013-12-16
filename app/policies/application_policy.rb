class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def manage?
    user.is_admin?
  end

  def index?
    user.is_staff?
  end

  def inspect?
    user.is_staff? or manage?
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def access?
    manage? or user.is_staff?
  end

  def create?
    manage?
  end

  def new?
    create?
  end

  def update?
    manage?
  end

  def edit?
    update?
  end

  def destroy?
    manage?
  end

  def use?
    manage?
  end

  def transfer?
    manage? and user.is_admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.is_staff?
        scope.all
      elsif not user.competing? # TODO check for owner association
        scope.where(:owner_id => user.id)
      end
    end
  end
end

