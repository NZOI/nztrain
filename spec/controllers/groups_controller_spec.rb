require "spec_helper"

describe GroupsController do
  let(:group) { FactoryBot.create(:group) }

  before do
    sign_in user
  end

  context "as admin" do
    let(:user) { FactoryBot.create(:admin) }

    can_index :groups
    can_create :group, attributes: {name: "A unique name"}
    can_manage :group, attributes: {name: "A unique name"}
  end

  context "as a normal user" do
    let(:user) { FactoryBot.create(:user) }

    can_browse :groups
  end

  context "as an organiser" do
    let(:user) { FactoryBot.create(:organiser) }

    can_index :groups, params: {filter: "my"}
  end
end
