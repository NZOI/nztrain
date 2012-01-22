class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)

    if user.has_role? :superadmin
      # can do anything, including melting down the site
      can :manage, :all
      return
    elsif user.has_role? :admin
      # can do anything except for site development, infrastructural objects
      can :manage, :all
      cannot :manage, Role
      cannot :manage, User, :is_superadmin => true
      can :read, :all
      return
    end

    # add permission for guests here
    
    return if !user_signed_in? # anything below is only for logged in users
 
    ####### Following for all users #######
    # Objects owned by the user
    can :manage, [Problem ProblemSet], :user_id = user.id # to add can manage Group, Contest
    can [:read :create], Submission, :user_id = user.id
    can :update, User, :user_id = user.id
    # Can browse all users
    can :read, User
    # Permissions by virtue of being in a group
    can :read, Problem, Problem.users_group_can_read(user.id) do |problem|
      Problem.users_group_can_read(user.id).find(problem)
    end
    can :read, ProblemSet, ProblemSet.users_group_can_read(user.id) do |problemset|
      ProblemSet.users_group_can_read(user.id).find(problemset)
    end
    can :read Contest, Contest.users_group_can_read(user.id) do |contest|
      Contest.users_group_can_read(user.id).find(contest)
    end
    # if in a contest
    if Contest.user_currently_in.count>0 # note these do not affect admins or staff (because it is overridden)
      # Cannots because of being in a contest
      cannot :manage, [Problem ProblemSet Submission]
      # Permissions by virtue of being in a contest
      can :create, Submission
      # can read stuff in a contest user is currently doing
      can :read, Problem, Problem.currently_in_users_contest do |problem|
        Problem.currently_in_users_contest.find(problem)
      end
      can :read, ProblemSet, ProblemSet.currently_in_users_contest do |problemset|
        ProblemSet.currently_in_users_contest.find(problemset)
      end
      can :read, Submission, Submission.currently_in_users_contest do |submission|
        Submission.currently_in_users_contest.find(submission)
      end
    end

    user.roles.each do |role|
      case role.name
      when 'staff' # full read access
        can :read, :all
        can :create, [Problem ProblemSet Group Contest]
      when 'manager' # can create new groups, problems, problem sets, contests
        can :create, [Problem ProblemSet Group Contest]
      when 'author' # can create new problems, problem sets
        can :create, [Problem ProblemSet]
      end
    end


    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
