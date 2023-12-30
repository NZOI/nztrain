require 'spec_helper'

feature 'invitation and join request' do
  scenario 'group owner invites a user, and user accepts invitation to group' do
    @group = FactoryBot.create(:group, :owner => users(:organiser), :visibility => Group::VISIBILITY[:private], :membership => Group::MEMBERSHIP[:private])

    login_as users(:organiser), :scope => :user
    visit invites_members_group_path(@group)
    expect do
      within '#invite_member_form' do
        fill_in 'username', :with => users(:user).username
        click_on 'Invite'
      end
    end.to change{ @group.invitations.pending.count }.by(1)

    @invitation = @group.invitations.pending.where(:target_id => users(:user)).first

    expect(@group.members.exists?(users(:user).id)).to be false

    login_as users(:user), :scope => :user
    visit accounts_requests_path
    expect do
      within '.group_invitations_list' do
        accept_link = find :xpath, "//a[@href = '#{accept_members_group_path(@group, @invitation)}']"
        accept_link.click
      end
    end.to change{ @group.invitations.pending.count }.by(-1)

    expect(@group.members.exists?(users(:user).id)).to be true
  end

  scenario 'group member invites a user and cancels the invitation' do
    @group = FactoryBot.create(:group, :members => [users(:user)], :visibility => Group::VISIBILITY[:private], :membership => Group::MEMBERSHIP[:invitation])
    
    login_as users(:user), :scope => :user
    visit invites_members_group_path(@group)
    
    expect do
      within '#invite_member_form' do
        fill_in 'username', :with => users(:organiser).username
        click_on 'Invite'
      end
    end.to change{ @group.invitations.pending.count }.by(1)

    @invitation = @group.invitations.pending.where(:target_id => users(:organiser)).first

    visit invites_members_group_path(@group)
    cancel_link = find :xpath, "//a[@href = '#{cancel_members_group_path(@group, @invitation)}']"
    expect{ cancel_link.click }.to change{ @group.invitations.pending.count }.by(-1)
  end

  scenario 'user applies to join group, and group member accepts join request' do
    @group = FactoryBot.create(:group, :owner => users(:organiser), :visibility => Group::VISIBILITY[:unlisted], :membership => Group::MEMBERSHIP[:invitation])

    login_as users(:user), :scope => :user
    visit group_path(@group)

    apply_link = find :xpath, "//a[@href = '#{apply_group_path(@group)}']"
    expect { apply_link.click }.to change{ @group.join_requests.pending.count }.by(1)

    expect(@group.members.exists?(users(:user).id)).to be false
    @join_request = @group.join_requests.pending.where(:subject_id => users(:user)).first

    login_as users(:organiser)
    visit join_requests_members_group_path(@group)
    accept_link = find :xpath, "//a[@href = '#{accept_members_group_path(@group, @join_request)}']"
    expect{ accept_link.click }.to change{ @group.join_requests.pending.count }.by(-1)

    expect(@group.members.exists?(users(:user).id)).to be true
  end

  scenario 'user applies to join group, and group owner rejects join request' do
    @group = FactoryBot.create(:group, :owner => users(:organiser), :visibility => Group::VISIBILITY[:public], :membership => Group::MEMBERSHIP[:application])

    login_as users(:user), :scope => :user
    visit group_path(@group)
    apply_link = find :xpath, "//a[@href = '#{apply_group_path(@group)}']"
    expect { apply_link.click }.to change{ @group.join_requests.pending.count }.by(1)

    @join_request = @group.join_requests.pending.where(:subject_id => users(:user)).first

    login_as users(:organiser)
    visit join_requests_members_group_path(@group)
    reject_link = find :xpath, "//a[@href = '#{reject_members_group_path(@group, @join_request)}']"
    expect{ reject_link.click }.to change{ @group.join_requests.pending.count }.by(-1)

    expect(@group.members.exists?(users(:user).id)).to be false
  end
end
