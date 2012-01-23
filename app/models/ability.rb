class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here
    user ||= User.new # guest user (not logged in)
    if user.is_superadmin
      # can do anything, including melting down the site
      can :manage, :all
      return
    elsif user.is_admin
      # can do anything except for site development, infrastructural objects
      can :manage, :all
      cannot :manage, Role
      cannot :manage, User, :is_superadmin => true
      can :read, :all
      return
    end

    ####### Following for all users #######
    # Users can do, whether or not they are in a contest
    # can [:update, :destroy], User, :user_id => user.id # Not used - account updated through the devise controller/views
    # Can browse all users
    can :read, User
    can :read, Contest, :groups.outer => {:users.outer => {:id => user.id}}
    if !Contest.user_currently_in(user.id).exists? # can do only if not in a contest
      # Objects owned by the user
      can :manage, [Problem, ProblemSet], :user_id => user.id # to add can manage Group, Contest
      can [:read, :create], Submission, :user_id => user.id
      # Permissions by virtue of being in a group
      can :read, Problem, :problem_sets.outer => {:groups.outer => {:users.outer => {:id => user.id}}} # ie. can read any problem in a problem set, assigned to a group that the user is part of
      can :read, ProblemSet, :groups.outer => {:users.outer => {:id => user.id}}
    else # in a contest (usual permissions to see problems not valid)
      # Permissions by virtue of being in a contest
      can :create, Submission
      # can read stuff in a contest user is currently doing
      can :read, Problem, :problem_sets.outer => {:contest.outer => {:users.outer => {:id => user.id}, :start_time => (DateTime.now-30.year)..DateTime.now, :end_time => DateTime.now..(DateTime.now+30.year)}}
      can :read, ProblemSet, :contest.outer => {:users.outer => {:id => user.id}, :start_time => (DateTime.now-30.year)..DateTime.now, :end_time => DateTime.now..(DateTime.now+30.year)}
      can :read, Submission, :problems.outer => {:problem_sets.outer => {:contest.outer => {:users.outer => {:id => user.id}, :start_time => (DateTime.now-30.year)..DateTime.now, :end_time => DateTime.now..(DateTime.now+30.year)}}}
    end
    cannot :create, [Problem, ProblemSet] # must secure evaluator
    user.roles.each do |role|
      case role.name
      when 'staff' # full read access
        can :read, :all
        can :create, [Problem, ProblemSet, Group, Contest]
      when 'manager' # can create new groups, problems, problem sets, contests
        can :create, [Problem, ProblemSet, Group, Contest]
      when 'author' # can create new problems, problem sets
        can :create, [Problem, ProblemSet]
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
