class Ability
  include CanCan::Ability
  # Note, :create, :update, :read, :destroy are the 4 RESTful actions controlled
  # :manage = all possible actions
  # Custom actions used:
  # :add_brownie, User
  # :use, [Problem, ProblemSet, Contest]
  # [:join, :leave], Group
  # [:grant, :revoke], Role (or :regrant for both abilities)
  # :inspect, [Problem, Contest] # to be implemented - intended to be a super-reader right
  #                               can see objects private info
  #                               eg. full contest scoreboard, object history
  # :start, Contest
  # :transfer, [Problem, ProblemSet, Contest, Group, Evaluator]

  def initialize(user)
    alias_action :read, :to => :inspect
    alias_action :grant, :revoke, :to => :regrant # roles, ie. move role privileges around to a different set of users
    # Define abilities for the passed in user here
    if user && user.confirmed?
      if user.is_superadmin?
        # can do anything, including melting down the site
        can :manage, :all
        return
      elsif user.is_admin?
        # can do anything except for site development, infrastructural objects
        can :manage, :all
        cannot :manage, Role
        cannot :manage, User, :is_superadmin? => true
        can :inspect, :all
        can :regrant, Role
        cannot :regrant, Role, :name => 'superadmin' # can assign all roles except superadmin
        cannot :manage, Setting # keys and passwords here
        cannot :destroy, Group, :id => 0 # cannot remove the "Everyone" group
        return
      end
    end

    ####### Abilities for guests

    return if !user # guest user (not logged in), no further abilities

    ####### Unconfirmed user
    #can :read, User, :id => user.id
    return unless user.confirmed?

    ####### Following abilities for all users #######
    # Users can do, whether or not they are in a contest
    if !Contest.user_currently_in(user.id).exists? # can do only if not in a contest
      # Objects owned by the user
      # FIXME: temporary fix due to bug caused by upgrading gem
      # can :manage, [Problem, ProblemSet, Evaluator, Group, Contest], :owner_id => user.id # this should not be commented
      cannot :create, [Problem, ProblemSet, Group, Contest, Evaluator] # though can manage, cannot create unless permission is given
      cannot :transfer, [Problem, ProblemSet, Evaluator, Group, Contest] # cannot transfer arbitrary objects unless vetted (by having role added)
      can :inspect, [TestCase], :test_set.outer => {:problem.outer => {:owner.outer => {:id => user.id}}}
      can :inspect, [TestSet], :problem.outer => {:owner.outer => {:id => user.id}}
      can :create, Problem
      can :read, Evaluator
      can [:read, :create], Submission, :user_id => user.id
      # Permissions by virtue of being in a group
      can :read, Problem, :problem_sets.outer => {:groups.outer => {:users.outer => {:id => [0,user.id]}}} # ie. can read any problem in a problem set, assigned to a group that the user is part of
      can :read, ProblemSet, :groups.outer => {:users.outer => {:id => [0,user.id]}}
    else # in a contest (usual permissions to see problems not valid)
      # Permissions by virtue of being in a contest
      can :create, Submission
      # can read stuff in a contest user is currently doing
      can :read, Problem, :problem_sets.outer => {:contests.outer => {:users.outer => {:id => user.id}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max}}
      can :read, ProblemSet, :contests.outer => {:users.outer => {:id => user.id}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max}
      can :read, Submission, :user_id => user.id, :problem.outer => {:problem_sets.outer => {:contests.outer => {:users.outer => {:id => user.id}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max}}}
    end

    ##### What all users can do whether they are in a contest or not

    # can [:update, :destroy], User, :id => user.id # Not used - account updated through the devise controller/views
    # Can browse all users
    can :read, User
    can :read, Group # for now, can see all groups, change later to can see public groups
    can :join, Group # can join all groups
    cannot :join, Group, :id => 0 # cannot join "Everyone"
    can :leave, Group, :users => {:id => user.id} # can leave any group user is part of
    can :index, Contest, :groups.outer => {:users.outer => {:id => [0,user.id]}}
    can :show, Contest, :groups.outer => {:users.outer => {:id => [0,user.id]}}, :end_time => DateTime.min...DateTime.now # can show contest if it has finished running
    can :start, Contest, :groups.outer => {:users.outer => {:id => [0,user.id]}}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max # allows user to start any contest for which they can read, if it is running
    can :show, Contest, :users.outer => {:id => user.id} # can show contest if user is a competitor

    user.roles.each do |role|
      case role.name
      when 'staff' # full read access
        can :inspect, :all
        can :add_brownie, User
        can :create, [Problem, ProblemSet, Group, Contest]
        can :regrant, Role
        cannot :regrant, Role, :name => ['superadmin','admin','staff'] # can only assign roles for lower tiers
        cannot :manage, Setting # keys and passwords here
      when 'organiser' # can create new groups, problems, problem sets, contests
        can :manage, [Problem, ProblemSet, Evaluator, Group, Contest], :owner_id => user.id
        can :create, [Problem, ProblemSet, Group, Contest]
      when 'author' # can create new problems, problem sets
        can :manage, [Problem, ProblemSet, Evaluator, Group, Contest], :owner_id => user.id
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
