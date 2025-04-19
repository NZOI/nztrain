require "spec_helper"

describe "Authorization" do
  let(:superadmin) { FactoryBot.create(:superadmin) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:user) { FactoryBot.create(:user) }
  let(:organiser) { FactoryBot.create(:organiser) }

  let(:group) { FactoryBot.create(:group, members: [user, admin, superadmin]) }
  let(:organiser_group) { FactoryBot.create(:group, owner: organiser, members: [user]) }

  let(:group_set) { FactoryBot.create(:problem_set, groups: [group]) }
  let(:everyone_set) { FactoryBot.create(:problem_set, group_ids: [0]) }

  let(:private_problem) { FactoryBot.create(:problem) }
  let(:group_problem) { FactoryBot.create(:problem, problem_sets: [group_set]) }
  let(:user_problem) { FactoryBot.create(:problem, owner: user) }
  let(:admin_problem) { FactoryBot.create(:problem, owner: admin) }
  let(:everyone_problem) { FactoryBot.create(:problem, problem_sets: [everyone_set]) }
  let(:contest_problem) { FactoryBot.create(:problem, problem_sets: [contest_set]) }

  let(:contest_set) { FactoryBot.create(:problem_set) }
  let(:private_set) { FactoryBot.create(:problem_set) }

  let(:private_contest) { FactoryBot.create(:contest, problem_set: contest_set) }

  let(:contest) do
    FactoryBot.create(
      :contest,
      groups: [group],
      problem_set: contest_set,
      start_time: 100.hours.ago,
      end_time: 100.hours.from_now
    )
  end

  let(:past_contest) do
    FactoryBot.create(
      :contest,
      groups: [group],
      problem_set: contest_set,
      start_time: 100.hours.ago,
      end_time: 50.hours.ago
    )
  end

  let(:future_contest) do
    FactoryBot.create(
      :contest,
      groups: [group],
      problem_set: contest_set,
      start_time: 100.hours.from_now,
      end_time: 20.hours.from_now
    )
  end

  let(:everyone_contest) do
    FactoryBot.create(
      :contest,
      groups: [group],
      problem_set: contest_set,
      start_time: 100.hours.ago,
      end_time: 100.hours.from_now
    )
  end

  describe "on models" do
    it "superadmin can manage all objects" do
      expect(superadmin).to be_permitted_to :manage, [Problem, Setting, Role, User, Group, Evaluator, Contest]
    end

    it "admin can manage most objects" do
      expect(admin).to be_permitted_to :manage, [Problem, Evaluator, Contest, Problem.new, Group.new, Contest.new, user, admin, group]
    end

    it "admin cannot manage Role, Setting, group for everyone, and superadmin user" do
      expect(admin).not_to be_permitted_to :manage, [Setting, Role, Group.find(0), superadmin]
    end

    it "user cannot see Role or Setting" do
      expect(user).not_to be_permitted_to [:index, :show, :edit, :new], [Setting, Role]
    end
  end
  describe "on problems" do
    it "admin can :manage all problems" do
      expect(admin).to be_permitted_to [:show, :manage], [private_problem, group_problem, user_problem, admin_problem, everyone_problem, contest_problem]
    end
    it "user can read group or public problems" do
      expect(user).to be_permitted_to :show, everyone_problem
      expect(user).to be_permitted_to :show, [group_problem, everyone_problem]
    end
    it "user can read/update owned problem" do
      expect(user).to be_permitted_to [:index, :show, :edit, :update], user_problem
    end
    it "user cannot read private problems" do
      expect(user).not_to be_permitted_to [:index, :show, :update], [private_problem, admin_problem, contest_problem]
    end
    it "user can create problem" do
      expect(user).to be_permitted_to [:new, :create], Problem.new(owner_id: user.id)
    end
    context "user in contest" do
      before do
        FactoryBot.create(:contest_relation, user_id: user.id, contest_id: contest.id, started_at: DateTime.now.advance(hours: -1))
      end

      it "can read contest problem" do
        expect(user).to be_permitted_to :show, [contest_problem]
      end

      it "cannot read/update other problems" do
        expect(user).not_to be_permitted_to [:index, :show, :update], [private_problem, admin_problem, user_problem]
      end
    end
  end

  describe "on problem sets" do
    it "admin can :manage all problem sets" do
      expect(admin).to be_permitted_to [:show, :manage], [private_set, group_set, contest_set, everyone_set]
    end

    it "user cannot read private or contest problem sets" do
      expect(user).not_to be_permitted_to [:index, :show, :update], [private_set, contest_set]
    end

    context "user in contest" do
      before do
        FactoryBot.create(:contest_relation, user_id: user.id, contest_id: contest.id, started_at: DateTime.now.advance(hours: -1))
      end

      it "cannot read/update other problems" do
        expect(user.reload).not_to be_permitted_to [:index, :show, :update], [private_set, group_set, everyone_set]
      end
    end
  end
  describe "on groups" do
    let(:new_user) { FactoryBot.create(:user) }

    it "members can invite users to open group" do
      organiser_group.update_attributes(visibility: Group::VISIBILITY[:public], membership: Group::MEMBERSHIP[:open])
      expect(organiser).to be_permitted_to [:invite, :reject], organiser_group
      expect(user).to be_permitted_to :invite, organiser_group
      expect(user).not_to be_permitted_to :reject, organiser_group
      expect(admin).to be_permitted_to [:invite, :reject], organiser_group
    end

    it "members can invite users if group membership is by invitation" do
      organiser_group.update_attributes(visibility: Group::VISIBILITY[:public], membership: Group::MEMBERSHIP[:invitation])
      expect(user).to be_permitted_to :invite, organiser_group
      expect(user).not_to be_permitted_to :reject, organiser_group
    end

    it "members cannot invite users if group membership is by application" do
      organiser_group.update_attributes(visibility: Group::VISIBILITY[:public], membership: Group::MEMBERSHIP[:application])
      expect(user).not_to be_permitted_to :invite, organiser_group
    end

    it "user can invite others to join if group membership is by invitation" do
      organiser_group.update_attributes(visibility: Group::VISIBILITY[:public], membership: Group::MEMBERSHIP[:invitation])
      expect(user).to be_permitted_to :invite, organiser_group
    end

    it "user can apply to join if group membership is by application" do
      organiser_group.update_attributes(visibility: Group::VISIBILITY[:public], membership: Group::MEMBERSHIP[:application])
      expect(new_user).to be_permitted_to :apply, organiser_group
    end

    it "user cannot see, nor apply to private visibility groups, even if membership settings otherwise allow it" do
      organiser_group.update_attributes(visibility: Group::VISIBILITY[:private], membership: Group::MEMBERSHIP[:invitation])
      expect(new_user).not_to be_permitted_to [:show, :apply], organiser_group
    end
  end

  describe "on contests" do
    it "user can index contest in group or for everyone" do
      expect(user).to be_permitted_to :index, [contest, everyone_contest, past_contest, future_contest]
      expect(user).to be_permitted_to :show, [contest, everyone_contest, past_contest]
    end

    it "user cannot index private contests" do
      expect(user).not_to be_permitted_to [:index, :show], private_contest
    end

    it "user can start active contest" do
      expect(user).to be_permitted_to :start, [contest, everyone_contest]
    end
  end
end
