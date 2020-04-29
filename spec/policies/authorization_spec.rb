require 'spec_helper'

describe "Authorization" do
  include FixturesSpecHelper
  before(:all) do
    @superadmin = users(:superadmin)
    @admin = users(:admin)
    @organiser = users(:organiser)
    @user = users(:user)
    # various objects to test ability on
    @member = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group, :members => [users(:user), users(:admin), users(:superadmin), @member])
    @organiser_group = FactoryGirl.create(:group, :owner => users(:organiser), :members => [@member])
    @private_problem = FactoryGirl.create(:problem)
    @group_set = FactoryGirl.create(:problem_set, :groups => [@group])
    @everyone_set = FactoryGirl.create(:problem_set, :group_ids => [0])
    @group_problem = FactoryGirl.create(:problem, :problem_sets => [@group_set])
    @user_problem = FactoryGirl.create(:problem, :owner => users(:user))
    @admin_problem = FactoryGirl.create(:problem, :owner => users(:admin))
    @everyone_problem = FactoryGirl.create(:problem, :problem_sets => [@everyone_set])
    @contest_set = FactoryGirl.create(:problem_set)
    @contest = FactoryGirl.create(:contest, :name => "Contest", :groups => [@group], :problem_set => @contest_set, :duration => 100, :start_time => DateTime.now.advance(:hours => -100), :end_time => DateTime.now.advance(:hours => 100))
    @contest_problem = FactoryGirl.create(:problem, :problem_sets => [@contest_set])
    @private_set = FactoryGirl.create(:problem_set)
    @private_contest = FactoryGirl.create(:contest, :problem_set => @contest_set)
    @past_contest = FactoryGirl.create(:contest, :groups => [@group], :problem_set => @contest_set, :start_time => DateTime.now.advance(:hours => -100), :end_time => DateTime.now.advance(:hours => -50))
    @future_contest = FactoryGirl.create(:contest, :groups => [@group], :problem_set => @contest_set, :start_time => DateTime.now.advance(:hours => 100), :end_time => DateTime.now.advance(:hours => 200))
    @everyone_contest = FactoryGirl.create(:contest, :group_ids => [0], :problem_set => @contest_set, :start_time => DateTime.now.advance(:hours => -100), :end_time => DateTime.now.advance(:hours => 100))
  end
  after(:all) do
    [@member, @group, @organiser_group, @private_problem, @group_set, @everyone_set, @group_problem, @user_problem, @admin_problem, @everyone_problem, @contest_set, @contest, @contest_problem, @private_set, @private_contest, @past_contest, @future_contest, @everyone_contest].reverse_each { |obj| obj.destroy }
  end
  describe 'on models' do
    it 'superadmin can manage all objects' do
      expect(@superadmin).to be_permitted_to :manage, [Problem, Setting, Role, User, Group, Evaluator, Contest]
    end
    it 'admin can manage most objects' do
      expect(@admin).to be_permitted_to :manage, [Problem, Evaluator, Contest, Problem.new, Group.new, Contest.new, @user, @admin, @group]
    end
    it 'admin cannot manage Role, Setting, group for everyone, and superadmin user' do
      expect(@admin).not_to be_permitted_to :manage, [Setting, Role, Group.find(0), @superadmin]
    end
    it 'user cannot see Role or Setting' do
      expect(@user).not_to be_permitted_to [:index,:show,:edit,:new], [Setting, Role]
    end
  end
  describe 'on problems' do
    it 'admin can :manage all problems' do
      expect(@admin).to be_permitted_to [:show,:manage], [@private_problem, @group_problem, @user_problem, @admin_problem, @everyone_problem, @contest_problem]
    end
    it 'user can read group or public problems' do
      expect(@user).to be_permitted_to :show, @everyone_problem
      expect(@user).to be_permitted_to :show, [@group_problem, @everyone_problem]
    end
    it 'user can read/update owned problem' do
      expect(@user).to be_permitted_to [:index, :show, :edit, :update], @user_problem
    end
    it 'user cannot read private problems' do
      expect(@user).not_to be_permitted_to [:index, :show, :update], [@private_problem, @admin_problem, @contest_problem]
    end
    it 'user can create problem' do
      expect(@user).to be_permitted_to [:new, :create], Problem.new(:owner_id => users(:user).id)
    end
    context 'user in contest' do
      before(:all) do
        @relation = FactoryGirl.create(:contest_relation, :user_id => users(:user).id, :contest_id => @contest.id, :started_at => DateTime.now.advance(:hours => -1))
        @contest_problem.reload
        @contest_user = users(:user).reload
      end
      after(:all) do
        @relation.destroy
        @contest_problem.reload
        @contest_user.reload
      end
      it 'can read contest problem' do
        expect(@contest_user).to be_permitted_to :show, [@contest_problem]
      end
      it 'cannot read/update other problems' do
        expect(@contest_user).not_to be_permitted_to [:index, :show, :update], [@private_problem, @admin_problem, @user_problem]
      end
    end
  end
  describe 'on problem sets' do
    it 'admin can :manage all problem sets' do
      expect(@admin).to be_permitted_to [:show,:manage], [@private_set, @group_set, @contest_set, @everyone_set]
    end
    # removed feature
    #it 'user can read group or public problem sets' do
    #  expect(@user).to be_permitted_to :show, [@group_set, @everyone_set]
    #end
    it 'user cannot read private or contest problem sets' do
      expect(@user).not_to be_permitted_to [:index, :show, :update], [@private_set, @contest_set]
    end
    context 'user in contest' do
      before(:all) do
        @relation = FactoryGirl.create(:contest_relation, :user_id => users(:user).id, :contest_id => @contest.id, :started_at => DateTime.now.advance(:hours => -1))
        @contest_user = users(:user).reload # refresh .competing?
      end
      after(:all) do
        @relation.destroy
        users(:user).reload
      end
      it 'cannot read/update other problems' do
        expect(@contest_user).not_to be_permitted_to [:index, :show, :update], [@private_set, @group_set, @everyone_set]
      end
    end
  end
  describe 'on groups' do
    it 'members can invite users to open group' do
      @organiser_group.update_attributes(:visibility => Group::VISIBILITY[:public], :membership => Group::MEMBERSHIP[:open])
      expect(@organiser).to be_permitted_to [:invite, :reject], @organiser_group
      expect(@member).to be_permitted_to :invite, @organiser_group
      expect(@member).not_to be_permitted_to :reject, @organiser_group
      expect(@admin).to be_permitted_to [:invite, :reject], @organiser_group
    end
    it 'members can invite users if group membership is by invitation' do
      @organiser_group.update_attributes(:visibility => Group::VISIBILITY[:public], :membership => Group::MEMBERSHIP[:invitation])
      expect(@member).to be_permitted_to :invite, @organiser_group
      expect(@member).not_to be_permitted_to :reject, @organiser_group
    end
    it 'members cannot invite users if group membership is by application' do
      @organiser_group.update_attributes(:visibility => Group::VISIBILITY[:public], :membership => Group::MEMBERSHIP[:application])
      expect(@member).not_to be_permitted_to :invite, @organiser_group
    end
    it 'user can apply to join if group membership is by invitation' do
      @organiser_group.update_attributes(:visibility => Group::VISIBILITY[:public], :membership => Group::MEMBERSHIP[:invitation])
      expect(@user).to be_permitted_to :apply, @organiser_group
    end
    it 'user can apply to join if group membership is by application' do
      @organiser_group.update_attributes(:visibility => Group::VISIBILITY[:public], :membership => Group::MEMBERSHIP[:application])
      expect(@user).to be_permitted_to :apply, @organiser_group
    end
    it 'user cannot see, nor apply to private visibility groups, even if membership settings otherwise allow it' do
      @organiser_group.update_attributes(:visibility => Group::VISIBILITY[:private], :membership => Group::MEMBERSHIP[:invitation])
      expect(@user).not_to be_permitted_to [:show, :apply], @organiser_group
    end
  end
  describe 'on contests' do
    it 'user can index contest in group or for everyone' do
      expect(@user).to be_permitted_to :index, [@contest, @everyone_contest, @past_contest, @future_contest]
      expect(@user).to be_permitted_to :show, [@contest, @everyone_contest, @past_contest]
    end
    it 'user cannot index private contests' do
      expect(@user).not_to be_permitted_to [:index, :show], @private_contest
    end
    it 'user can start active contest' do
      expect(@user).to be_permitted_to :start, [@contest, @everyone_contest]
    end
  end
end
