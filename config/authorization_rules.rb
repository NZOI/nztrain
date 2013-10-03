authorization do
  role :superadmin do
    has_omnipotence
  end
  role :admin do
    includes :staff
    has_permission_on :roles, :to => :inspect
    has_permission_on :roles, :to => :regrant do
      if_attribute :name => is_not{'superadmin'}
    end
    has_permission_on :users, :to => :manage do
      if_attribute :is_superadmin? => is_not{true}, :id => is_not{0}
    end
    has_permission_on :users, :to => :su do
      if_attribute :is_superadmin? => is_not{true}, :is_admin? => is_not{true}, :id => is_not{0}
    end
    has_permission_on :groups, :to => :manage do
      if_attribute :id => is_not{0}
    end
    has_permission_on :requests, :to => [:accept, :reject, :cancel] do
      if_attribute :pending? => is{true}
    end
    has_permission_on [:problems, :problem_sets, :contests, :test_cases, :test_sets, :evaluators, :submissions, :file_attachments], :to => :manage
    has_permission_on :contests, :to => [:finalize, :unfinalize]
  end
  role :staff do
    includes :organiser
    has_permission_on :users, :to => [:inspect, :add_brownie]
    has_permission_on :groups, :to => :inspect
    has_permission_on :problems, :problem_sets, :contest, :test_cases, :test_sets, :evaluators, :to => :inspect
    has_permission_on :roles, :to => :read
    has_permission_on :roles, :to => :regrant, :join_by => :and do
      if_attribute :name => is_not{'superadmin'}
      if_attribute :name => is_not{'admin'}
      if_attribute :name => is_not{'staff'}
    end
    has_permission_on [:problems, :problem_sets, :contests, :test_cases, :test_sets, :evaluators, :submissions], :to => :inspect
    has_permission_on :problems, :to => :submit
    has_permission_on [:problems, :problem_sets], :to => :transfer do
      if_attribute :owner => is{user}
    end

    has_permission_on :file_attachments, :to => :manage do
      if_attribute :owner => is{user}
    end
  end
  role :organiser do
    includes :author
    has_permission_on :groups, :to => :manage do
      if_attribute :owner => is{user}
    end
    has_permission_on :contests, :to => :manage do
      if_attribute :owner => is{user}
    end
  end
  role :author do
    has_permission_on :problem_sets, :to => :manage do
      if_attribute :owner => is{user}
    end
  end
  role :user do
    has_permission_on :users, :to => :read
    has_permission_on :contests, :to => :read do
      if_attribute :groups => {:id => 0}
      if_attribute :groups => {:members => contains{user}}
      if_attribute :contest_relations => {:user => is{user}}
    end
    has_permission_on :contests, :to => :start, :join_by => :and do
      if_attribute :contestants => does_not_contain{user}, :start_time => lte{DateTime.now}, :end_time => gt{DateTime.now}
      if_permitted_to :index
    end
    has_permission_on :contests, :to => :scoreboard do
      if_attribute :groups => {:id => 0}, :start_time => lte{DateTime.now}
      if_attribute :groups => {:members => contains{user}}, :start_time => lte{DateTime.now}
      if_attribute :contest_relations => {:user => is{user}}, :start_time => lte{DateTime.now}
    end
    has_permission_on :groups, :to => :index do
      if_attribute :visibility => Group::VISIBILITY[:public]
    end
    has_permission_on :groups, :to => :show do
      if_attribute :visibility => Group::VISIBILITY[:public]
      if_attribute :visibility => Group::VISIBILITY[:unlisted]
      if_attribute :members => contains{user}
    end
    has_permission_on :groups, :to => :access do
      if_attribute :id => 0
      if_attribute :members => contains{user}
    end
    has_permission_on :groups, :to => :join do
      if_attribute :members => does_not_contain{user}, :id => is_not{0}, :membership => Group::MEMBERSHIP[:open]
    end
    has_permission_on :groups, :to => :leave do
      if_attribute :members => contains{user}
    end
    has_permission_on :groups, :to => :invite do
      if_attribute :members => contains{user}, :membership => Group::MEMBERSHIP[:open]
      if_attribute :members => contains{user}, :membership => Group::MEMBERSHIP[:invitation]
    end
    has_permission_on :groups, :to => :apply do
      if_attribute :members => does_not_contain{user}, :id => is_not{0},
                   :membership => Group::MEMBERSHIP[:invitation], :visibility => is_not{Group::VISIBILITY[:private]}
      if_attribute :members => does_not_contain{user}, :id => is_not{0},
                   :membership => Group::MEMBERSHIP[:application], :visibility => is_not{Group::VISIBILITY[:private]}
    end
    has_permission_on :submissions, :to => :read do
      if_attribute :problem => {:problem_sets => {:contests => {:contest_relations => {:user => is{user}, :started_at => lte{DateTime.now}, :finish_at => gt{DateTime.now}, :started_at => lte{object.created_at}}}}}
    end
    has_permission_on :problems, :to => :submit do
      if_permitted_to :read
    end
    has_permission_on :contests, :to => :access_problems do
      if_attribute :contest_relations => {:user => is{user}, :started_at => lte{DateTime.now}, :finish_at => gt{DateTime.now}}
    end
    has_permission_on :problems, :to => :read do
      if_attribute :problem_sets => {:contests => {:contest_relations => {:user => is{user}, :started_at => lte{DateTime.now}, :finish_at => gt{DateTime.now}}}}
    end
    has_permission_on :problem_sets, :to => :browse
    has_permission_on :users, :to => :suexit

    has_permission_on :requests, :to => [:accept, :reject] do
      if_attribute :requestee => is{user}, :pending? => is{true}
    end
    has_permission_on :requests, :to => :cancel do
      if_attribute :requester => is{user}, :pending? => is{true}
    end
  end
  # user in closed book contest
  role :closedbook do
  end
  # users not in a contest or in open book contest
  role :openbook do
    has_permission_on :groups, :to => [:access_problems, :access_files] do
      if_attribute :id => 0
      if_attribute :members => contains { user }
      if_attribute :owner => is{user}
    end
    has_permission_on :problems, :to => :manage do
      if_attribute :owner => is{user}
    end
    has_permission_on :problems, :to => :read do
      if_attribute :problem_sets => {:groups => {:members => contains{user}}}
      if_attribute :problem_sets => {:groups => {:id => 0}}
    end
    has_permission_on :problems, :to => :create do
      if_attribute :owner => is{user}
    end
    has_permission_on :submissions, :to => :read do
      if_attribute :user => is{user}
      if_attribute :problem => {:owner => is{user}}
    end
  end
  role :guest do

  end
end
privileges do
  privilege :manage do
    includes :create, :inspect, :update, :delete, :use, :access, :access_problems, :access_files, :invite, :reject
  end
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
  privilege :regrant, :includes => [:grant, :revoke]
  privilege :read, :includes => [:index, :show]
  privilege :inspect, :includes => [:read, :scoreboard, :download]
  privilege :access_problems, :includes => [:read_problems, :submit_problems]
  privilege :index, :includes => :browse
end
