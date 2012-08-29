require 'spec_helper'

describe Ability do
  include FixturesSpecHelper
  include AbilitySpecHelper
  before(:all) do
    @superadmin = Ability.new(users(:superadmin))
    @admin = Ability.new(users(:admin))
    @user = Ability.new(users(:user))
    # various objects to test ability on
    @group = FactoryGirl.create(:group, :users => [users(:user), users(:admin), users(:superadmin)])
    @private_problem = FactoryGirl.create(:problem)
    @group_set = FactoryGirl.create(:problem_set, :groups => [@group])
    @everyone_set = FactoryGirl.create(:problem_set, :group_ids => [0])
    @group_problem = FactoryGirl.create(:problem, :problem_sets => [@group_set])
    @user_problem = FactoryGirl.create(:problem, :owner => users(:user))
    @admin_problem = FactoryGirl.create(:problem, :owner => users(:admin))
    @everyone_problem = FactoryGirl.create(:problem, :problem_sets => [@everyone_set])
    @contest_set = FactoryGirl.create(:problem_set)
    @contest = FactoryGirl.create(:contest, :groups => [@group], :problem_set => @contest_set, :duration => 100, :start_time => DateTime.now.advance(:hours => -100), :end_time => DateTime.now.advance(:hours => 100))
    @contest_problem = FactoryGirl.create(:problem, :problem_sets => [@contest_set])
    @private_set = FactoryGirl.create(:problem_set)
    @private_contest = FactoryGirl.create(:contest, :problem_set => @contest_set)
    @past_contest = FactoryGirl.create(:contest, :groups => [@group], :problem_set => @contest_set, :start_time => DateTime.now.advance(:hours => -100), :end_time => DateTime.now.advance(:hours => -50))
    @future_contest = FactoryGirl.create(:contest, :groups => [@group], :problem_set => @contest_set, :start_time => DateTime.now.advance(:hours => 100), :end_time => DateTime.now.advance(:hours => 200))
    @everyone_contest = FactoryGirl.create(:contest, :group_ids => [0], :problem_set => @contest_set, :start_time => DateTime.now.advance(:hours => -100), :end_time => DateTime.now.advance(:hours => 100))
  end
  after(:all) do
    [@group, @private_problem, @group_set ,@everyone_set, @group_problem, @user_problem, @admin_problem, @everyone_problem, @contest_set, @contest, @contest_problem, @private_set, @private_contest, @past_contest, @future_contest, @everyone_contest].each { |obj| obj.destroy }
  end
  describe 'on models' do
    it 'superadmin can manage all objects' do
      @superadmin.should be_able_to_do_all :manage, [Problem, Setting, Role, User, Group, Evaluator, Contest]
    end
    it 'admin can manage most objects' do
      @admin.should be_able_to_do_all :manage, [Problem, User, Group, Evaluator, Contest]
    end
    it 'admin cannot manage Role or Setting' do
      @admin.should not_be_able_to_do_any :manage, [Setting, Role]
    end
    it 'user cannot see Role or Setting' do
      @user.should not_be_able_to_do_any [:index,:show,:edit,:new], [Setting, Role]
    end
  end
  describe 'on problems' do
    it 'admin can :manage all problems' do
      @admin.should be_able_to_do_all [:read,:manage], [@private_problem, @group_problem, @user_problem, @admin_problem, @everyone_problem, @contest_problem]
    end
    it 'user can read group or public problems' do
      @user.should be_able_to_do_all :read, [@group_problem, @everyone_problem]
    end
    it 'user can read/update owned problem' do
      @user.should be_able_to_do_all [:index, :read, :edit, :update], @user_problem
    end
    it 'user cannot read private problems' do
      @user.should not_be_able_to_do_any [:index, :read, :update], [@private_problem, @admin_problem, @contest_problem]
    end
    it 'user can index group, public or owned problems' do
      Problem.accessible_by(@user).map(&:id).should include(@group_problem.id, @everyone_problem.id, @user_problem.id)
    end
    it 'user cannot index private problems' do
      Problem.accessible_by(@user).map(&:id).should_not include(@private_problem.id, @admin_problem.id, @contest_problem.id)
    end
    it 'admin can index all problems' do
      Problem.accessible_by(@admin).map(&:id).should include(@group_problem.id, @everyone_problem.id, @user_problem.id, @private_problem.id, @admin_problem.id)
    end
    it 'user can create problem' do
      @user.should be_able_to_do_all [:new, :create], Problem.new(:owner_id => users(:user).id)
    end
    context 'user in contest' do
      before(:all) do
        @relation = FactoryGirl.create(:contest_relation, :user_id => users(:user).id, :contest_id => @contest.id, :started_at => DateTime.now.advance(:hours => -1))
        @contest_user = Ability.new(users(:user))
      end
      after(:all) do
        @relation.destroy
      end
      it 'can index contest problem' do
        Problem.accessible_by(@contest_user).map(&:id).should include(@contest_problem.id)
      end
      it 'cannot index other problems' do
        Problem.accessible_by(@contest_user).map(&:id).should_not include(@user_problem.id, @group_problem.id, @everyone_problem.id, @private_problem.id)
      end
      it 'can read contest problem' do
        @contest_user.should be_able_to_do_all :read, [@contest_problem]
      end
      it 'cannot read/update other problems' do
        @contest_user.should not_be_able_to_do_any [:index, :read, :update], [@private_problem, @admin_problem, @user_problem]
      end
    end
  end
  describe 'on problem sets' do
    it 'admin can :manage all problem sets' do
      @admin.should be_able_to_do_all [:read,:manage], [@private_set, @group_set, @contest_set, @everyone_set]
    end
    it 'user can read group or public problem sets' do
      @user.should be_able_to_do_all :read, [@group_set, @everyone_set]
    end
    it 'user cannot read private or contest problem sets' do
      @user.should not_be_able_to_do_any [:index, :read, :update], [@private_set, @contest_set]
    end
    it 'user can index group, public or owned problem sets' do
      ProblemSet.accessible_by(@user).map(&:id).should include(@group_set.id, @everyone_set.id)
    end
    it 'user cannot index private problem sets' do
      ProblemSet.accessible_by(@user).map(&:id).should_not include(@private_set.id, @contest_set.id)
    end
    it 'admin can index all problem sets' do
      ProblemSet.accessible_by(@admin).map(&:id).should include(@private_set.id, @contest_set.id, @group_set.id, @everyone_set.id)
    end
    context 'user in contest' do
      before(:all) do
        @relation = FactoryGirl.create(:contest_relation, :user_id => users(:user).id, :contest_id => @contest.id, :started_at => DateTime.now.advance(:hours => -1))
        @contest_user = Ability.new(users(:user))
      end
      after(:all) do
        @relation.destroy
      end
      it 'can index contest problem' do
        ProblemSet.accessible_by(@contest_user).map(&:id).should include(@contest_set.id)
      end
      it 'cannot index other problems' do
        ProblemSet.accessible_by(@contest_user).map(&:id).should_not include(@private_set.id, @group_set.id, @everyone_set.id)
      end
      it 'can read contest problem' do
        @contest_user.should be_able_to_do_all :read, [@contest_set]
      end
      it 'cannot read/update other problems' do
        @contest_user.should not_be_able_to_do_any [:index, :read, :update], [@private_set, @group_set, @everyone_set]
      end
    end
  end
  describe 'contests' do
    it 'user can index contest in group or for everyone' do
      @user.should be_able_to_do_all :index, [@contest, @everyone_contest, @past_contest, @future_contest]
      @user.should be_able_to_do_all :show, [@contest, @everyone_contest, @past_contest]
    end
    it 'user cannot show a future contest' do
      @user.should not_be_able_to_do_any :show, @future_contest
    end
    it 'user cannot index private contests' do
      @user.should not_be_able_to_do_any [:index, :show], @private_contest
    end
    it 'user can start active contest' do
      @user.should be_able_to_do_all :start, [@contest, @everyone_contest]
    end
    it 'user cannot start past or future contests' do
      @user.should not_be_able_to_do_any :start, [@past_contest, @future_contest]
    end
  end
end
