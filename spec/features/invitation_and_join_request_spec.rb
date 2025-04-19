require "spec_helper"

feature "invitation and join request" do
  subject(:group) { FactoryBot.create(:group, owner: owner, members: members, visibility: visibility, membership: membership) }

  let(:owner) { FactoryBot.create(:organiser) }
  let(:member) { FactoryBot.create(:user) }
  let(:members) { [member] }
  let(:visibility) { Group::VISIBILITY[:unlisted] }
  let(:membership) { Group::MEMBERSHIP[:invitation] }

  let(:uninvited_user) { FactoryBot.create(:user) }

  context "when the group is private and invite-only" do
    let(:membership) { Group::MEMBERSHIP[:private] }
    let(:visibility) { Group::VISIBILITY[:private] }

    scenario "group owner invites a user, and user accepts invitation to group" do
      login_as owner, scope: :user
      visit invites_members_group_path(group)
      expect do
        within "#invite_member_form" do
          fill_in "username", with: uninvited_user.username
          click_on "Invite"
        end
      end.to change { group.invitations.pending.count }.by(1)

      invitation = group.invitations.pending.where(target: uninvited_user).first

      expect(group.members.exists?(uninvited_user.id)).to be false

      login_as uninvited_user, scope: :user
      visit accounts_requests_path

      expect do
        within ".group_invitations_list" do
          accept_link = find :xpath, "//a[@href = '#{accept_members_group_path(group, invitation)}']"
          accept_link.click
        end
      end.to change { group.invitations.pending.count }.by(-1)

      expect(group.members.exists?(uninvited_user.id)).to be true
    end
  end

  context "when the group unlisted and invite + apply" do
    let(:membership) { Group::MEMBERSHIP[:invitation] }
    let(:visibility) { Group::VISIBILITY[:unlisted] }

    scenario "group member invites a user and cancels the invitation" do
      login_as member, scope: :user
      visit invites_members_group_path(group)

      expect do
        within "#invite_member_form" do
          fill_in "username", with: uninvited_user.username
          click_on "Invite"
        end
      end.to change { group.invitations.pending.count }.by(1)

      invitation = group.invitations.pending.where(target_id: uninvited_user).first

      visit invites_members_group_path(group)
      cancel_link = find :xpath, "//a[@href = '#{cancel_members_group_path(group, invitation)}']"
      expect { cancel_link.click }.to change { group.invitations.pending.count }.by(-1)
    end

    scenario "uninvited user applies to join group, and group owner accepts join request" do
      login_as uninvited_user, scope: :user
      visit group_path(group)

      apply_link = find :xpath, "//a[@href = '#{apply_group_path(group)}']"
      expect { apply_link.click }.to change { group.join_requests.pending.count }.by(1)

      expect(group.members.exists?(uninvited_user.id)).to be false
      join_request = group.join_requests.pending.where(subject_id: uninvited_user).first

      login_as owner
      visit join_requests_members_group_path(group)
      accept_link = find :xpath, "//a[@href = '#{accept_members_group_path(group, join_request)}']"
      expect { accept_link.click }.to change { group.join_requests.pending.count }.by(-1)

      expect(group.members.exists?(uninvited_user.id)).to be true
    end
  end

  context "when the group is public and allows applications" do
    let(:visibility) { Group::VISIBILITY[:public] }
    let(:membership) { Group::MEMBERSHIP[:application] }

    scenario "user applies to join group, and group owner rejects join request" do
      login_as uninvited_user, scope: :user
      visit group_path(group)
      apply_link = find :xpath, "//a[@href = '#{apply_group_path(group)}']"
      expect { apply_link.click }.to change { group.join_requests.pending.count }.by(1)

      join_request = group.join_requests.pending.where(subject_id: uninvited_user).first

      login_as owner
      visit join_requests_members_group_path(group)
      reject_link = find :xpath, "//a[@href = '#{reject_members_group_path(group, join_request)}']"
      expect { reject_link.click }.to change { group.join_requests.pending.count }.by(-1)

      expect(group.members.exists?(uninvited_user.id)).to be false
    end
  end
end
