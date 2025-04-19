require "spec_helper"

describe UserController do
  before do
    sign_in user
  end

  context "as admin" do
    let(:user) { FactoryBot.create(:superadmin) }
    can_show :user
    can_update :user, attributes: {name: "A unique name"}
  end

  context "as a normal user" do
    let(:user) { FactoryBot.create(:user) }

    can_show :user
  end
end
