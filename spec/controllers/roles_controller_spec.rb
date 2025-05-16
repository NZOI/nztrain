require "spec_helper"

describe RolesController do
  let(:role) { FactoryBot.create(:role) }

  before do
    sign_in user
  end

  context "as superadmin" do
    let(:user) { FactoryBot.create(:superadmin) }

    can_index :roles
    can_create :role, attributes: {name: "A unique name"}
    can_manage :role, attributes: {name: "A unique name"}
  end

  context "as admin" do
    let(:user) { FactoryBot.create(:admin) }

    can_index :roles
  end
end
