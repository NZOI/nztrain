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
    # alias_action :read, :to => :inspect # will need to do this manually - because scopes on :read are unmergeable
    alias_action :grant, :revoke, :to => :regrant # roles, ie. move role privileges around to a different set of users

    # special abilities for admins
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
        can [:read, :inspect], :all
        can :regrant, Role
        cannot :regrant, Role, :name => 'superadmin' # can assign all roles except superadmin
        cannot :manage, Setting # keys and passwords here
        cannot :manage, [Group, User], :id => 0 # cannot manage the Everyone group, System user
        can [:read, :inspect], [Group, User], :id => 0
        return
      end
    end

    ####### Abilities for guests

    return if !user # guest user (not logged in), no further abilities

    ####### Unconfirmed user
    #can :read, User, :id => user.id
    return unless user.confirmed?

    initialize_user_abilities(user)
    initialize_contest_abilities(user)
    initialize_group_abilities(user)
    initialize_problem_abilities(user) # permissions for problem sets

    ####### Following abilities for all users #######
    # Users can do, whether or not they are in a contest
    #if !Contest.user_currently_in(user.id).exists? # can do only if not in a contest
      # Objects owned by the user
      ##can :manage, [Problem, ProblemSet, Evaluator, Group, Contest], :owner_id => user.id
      ##cannot :create, [ProblemSet, Group, Contest, Evaluator] # though can manage, cannot create unless permission is given
      ##cannot :transfer, [Problem, ProblemSet, Evaluator, Group, Contest] # cannot transfer arbitrary objects unless vetted (by having role added)
      # can :inspect, [TestCase], :test_set.outer => {:problem.outer => {:owner.outer => {:id => user.id}}}
      # can :inspect, [TestSet], :problem.outer => {:owner.outer => {:id => user.id}}
      #can :create, Problem
      ##can :read, Evaluator
      #can [:read, :create], Submission, :user_id => user.id
      # Permissions by virtue of being in a group
      #can :read, Problem, :id => Problem.joins(:problem_sets => {:groups => :users}).where(:users => {:id => user.id})
      #can :read, Problem, :id => Problem.joins(:problem_sets => :groups).where(:groups => {:id => 0})
      #can :read, Problem, :problem_sets.outer => {:groups.outer => {:users.outer => {:id => [0,user.id]}}} # ie. can read any problem in a problem set, assigned to a group that the user is part of
      #can :read, ProblemSet, :id => ProblemSet.joins(:groups => :users).where(:users => {:id => user.id})
      #can :read, ProblemSet, :id => ProblemSet.joins(:groups).where(:groups => {:id => 0})
      #can :read, ProblemSet, :groups.outer => {:users.outer => {:id => [0,user.id]}}
    #else # in a contest (usual permissions to see problems not valid)
      # Permissions by virtue of being in a contest
      #can :create, Submission, :user_id => user.id
      # can read stuff in a contest user is currently doing
      #can :read, Problem, :problem_sets.outer => {:contests.outer => {:users.outer => {:id => user.id}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max}}
      #can :read, Problem, :id => Problem.joins(:problem_sets => {:contests => :contest_relations}).where(:contest_relations => {:user_id => user.id}).where{{ contest_relations => sift(:is_active) }}
      #can :read, ProblemSet, :id => Contest.select(:problem_set_id).joins(:contest_relations).where(:contest_relations => {:user_id => user.id}).where{{ contest_relations => sift(:is_active) }}
      #can :read, Submission, :user_id => user.id, :problem_id => Problem.joins(:problem_sets => {:contests => :contest_relations}).where(:contest_relations => { :user_id => user.id}).where{{ contest_relations => sift(:is_active) }}
      #can :read, ProblemSet, :contests.outer => {:users.outer => {:id => user.id}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max}
      #can :read, Submission, :user_id => user.id, :problem.outer => {:problem_sets.outer => {:contests.outer => {:users.outer => {:id => user.id}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max}}}
    #end

    ##### What all users can do whether they are in a contest or not

    # can [:update, :destroy], User, :id => user.id # Not used - account updated through the devise controller/views
    # Can browse all users
    #can :read, User
    #can :read, Group # for now, can see all groups, change later to can see public groups
    #can :join, Group # can join all groups
    #cannot :join, Group, :id => 0 # cannot join "Everyone"
    #can :leave, Group, :id => user.groups
    #can :leave, Group, :users => {:id => user.id} # can leave any group user is part of
    #can :index, Contest, :id => Contest.joins(:groups => :users).where(:users => {:id => user.id})
    #can :index, Contest, :id => Contest.joins(:groups).where(:groups => {:id => 0})
    #can :index, Contest, :groups.outer => {:users.outer => {:id => [0,user.id]}}
    #can :show, Contest, :id => Contest.joins(:groups => :users).where(:users => {:id => user.id}, :end_time => DateTime.min...DateTime.now)
    #can :show, Contest, :id => Contest.joins(:groups).where(:groups => {:id => 0}, :end_time => DateTime.min...DateTime.now)
    #can :show, Contest, :groups.outer => {:users.outer => {:id => [0,user.id]}}, :end_time => DateTime.min...DateTime.now # can show contest if it has finished running
    #can :start, Contest, :id => Contest.joins(:groups => :users).where(:users => {:id => user.id}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max)
    #can :start, Contest, :id => Contest.joins(:groups).where(:groups => {:id => 0}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max)
    #can :start, Contest, :groups.outer => {:users.outer => {:id => [0,user.id]}}, :start_time => DateTime.min...DateTime.now, :end_time => DateTime.now..DateTime.max # allows user to start any contest for which they can read, if it is running
    #can :read, Contest, :id => ContestRelation.select(:contest_id).where(:user_id => user.id)
    #can :show, Contest, :users.outer => {:id => user.id} # can show contest if user is a competitor

    # other special permissions by role
    user.roles.each do |role|
      case role.name
      when 'staff' # full read access
        #can [:read, :inspect], [User]
        #can :add_brownie, User
        #can :create, [Group, Contest]
        can [:read, :regrant], Role
        cannot :regrant, Role, :name => ['superadmin','admin','staff'] # can only assign roles for lower tiers
        #cannot :manage, Setting # keys and passwords here
      when 'organiser' # can create new groups, problems, problem sets, contests
        #can :manage, [Problem, ProblemSet, Evaluator, Group, Contest], :owner_id => user.id
        #can :create, [Problem, ProblemSet, Group, Contest]
      when 'author' # can create new problems, problem sets
        #can :manage, [Problem, ProblemSet, Evaluator, Group, Contest], :owner_id => user.id
        #can :create, [Problem, ProblemSet]
      end
    end
  end
  def initialize_user_abilities(user)
    can :read, User
    can [:inspect, :add_brownie], User if user.is_staff?
  end
  def initialize_contest_abilities(user)
    can :index, Contest, Contest.where{ (owner_id == user.id) | sift(:for_group_user, user.id) | sift(:for_everyone) | sift(:for_contestant, user.id) } do |c|
      next true if c.owner_id == user.id
      if c.persisted?
        c.group_members.where(:id => user.id).any? || c.groups.where(:id => 0).any? || c.contest_relations.where(:user_id => user.id).any?
      else
        (c.group_members.map(&:id).include? user.id) || (c.groups.map(&:id).include? 0) || (c.contest_relations.map(&:user_id).include? user.id)
      end
    end
    # can show if you own the contest, it is placed in your group or Everyone or you are already a contestant
    can :show, Contest, Contest.where{ (owner_id == user.id) | (sift(:for_contestant, user.id) | (sift(:for_group_user, user.id) | sift(:for_everyone)) & (start_time <= DateTime.now)) } do |c|
      next true if c.owner_id == user.id
      next false if c.start_time > DateTime.now
      if c.persisted?
        c.group_members.where(:id => user.id).any? || c.groups.where(:id => 0).any? || c.contest_relations.where(:user_id => user.id).any?
      else
        (c.group_members.map(&:id).include? user.id) || (c.groups.map(&:id).include? 0) || (c.contest_relations.map(&:user_id).include? user.id)
      end
    end
    #can :show, Contest, :owner_id => user.id
    #can :show, Contest, :contest_relations => {:user_id => user.id}
    #can :show, Contest, :groups => {:id => 0}, :start_time => DateTime.min..DateTime.now
    #can :show, Contest, :groups => {:users => {:id => user.id}}, :start_time => DateTime.min..DateTime.now
    # can start if it is placed in your group or Everyone
    can :start, Contest, Contest.where{ ((-sift(:for_contestant, user.id)) & sift(:for_group_user, user.id) | sift(:for_everyone)) & (start_time <= DateTime.now) & (end_time > DateTime.now) } do |c|
      next true if c.owner_id == user.id
      next false if (c.start_time > DateTime.now) || (c.end_time <= DateTime.now)
      if c.persisted?
        (!c.contest_relations.where(:user_id => user.id).any?) && (c.group_members.where(:id => user.id).any? || c.groups.where(:id => 0).any?)
      else
        (!c.contest_relations.map(&:user_id).include? user.id) && ((c.group_members.map(&:id).include? user.id) || (c.groups.map(&:id).include? 0))
      end
    end
    #can :start, Contest, :groups => {:id => 0}, :start_time => DateTime.min..DateTime.now, :end_time => DateTime.now..DateTime.max
    #can :start, Contest, :groups => {:users => {:id => user.id}}, :start_time => DateTime.min..DateTime.now, :end_time => DateTime.now..DateTime.max
    # can manage if you own it
    can [:create, :update, :destroy], Contest, :owner_id => user.id if (user.is_any? [:staff, :organiser]) && !user.competing?
  end
  def initialize_group_abilities(user)
    can :read, Group
    can :join, Group # can join all groups
    cannot :join, Group, :id => 0 # cannot join "Everyone"
    can :leave, Group, :id => user.groups
    can [:create, :update, :destroy], Group, :owner_id => user.id if (user.is_any? [:staff, :organiser])
  end
  def initialize_problem_abilities(user) # abilities on problems, problem sets and submissions
    can :create, Submission # restrict further later - refactor to can :submit, Problem, ...
    if user.is_staff?
      can [:read, :inspect], [Problem,ProblemSet,Submission]
      can [:create, :transfer, :update, :destroy], [Problem,ProblemSet], :owner_id => user.id
    elsif user.competing?
      can :read, Problem, Problem.where{ sift(:for_contestant, user.id) } do |p|
        p.persisted? ? p.contest_relations.active.user(user.id).any? : p.contest_relations.any? do |relation|
          relation.active? && relation.user_id == user.id
        end
      end
      can :read, ProblemSet, ProblemSet.where{ sift(:for_contestant, user.id) } do |set|
        set.persisted? ? set.contest_relations.active.user(user.id).any? : set.contest_relations.any? do |relation|
          relation.active? && relation.user_id == user.id
        end
      end
      can :read, Submission, Submission.where{ sift(:for_contestant, user.id) } do |s|
        s.persisted? ? s.problem.contest_relations.active.user(user.id).any? : s.problem.contest_relations.any? do |relation|
          relation.active? && relation.user_id == user.id
        end
      end
    else
      if user.is_any? [:author,:organiser]
        can [:create,:update,:transfer,:destroy], [Problem,ProblemSet], :owner_id => user.id
      else
        can [:create,:update,:destroy], Problem, :owner_id => user.id
      end
      can :inspect, [Problem,ProblemSet], :owner_id => user.id

      can :read, Submission, :user_id => user.id
      can :read, Problem, Problem.where{ (owner_id == user.id) | sift(:for_group_user, user.id) | sift(:for_everyone) } do |p|
        next true if p.owner_id == user.id
        if p.persisted?
          p.group_members.where(:id => user.id).any? || p.groups.where(:id => 0).any?
        else
          (p.group_members.map(&:id).include? user.id) || (p.groups.map(&:id).include? 0)
        end
      end
      # can read sets in group or sets owned by user
      can :read, ProblemSet, ProblemSet.where{ sift(:for_owner, user.id) | sift(:for_group_user, user.id) | sift(:for_everyone) } do |set|
        next true if set.owner_id == user.id
        if set.persisted?
          set.group_members.where(:id => user.id).any? || set.groups.where(:id => 0).any?
        else
          (set.group_members.map(&:id).include? user.id) || (set.groups.map(&:id).include? 0)
        end
      end
    end
  end
end

