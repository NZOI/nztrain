require "spec_helper"

describe UsersController do
  before do
    sign_in user
  end

  context "as admin" do
    let(:user) { FactoryBot.create(:admin) }

    can_index :users
  end

  context "as a normal user" do
    let(:user) { FactoryBot.create(:user) }

    can_index :users
  end
end
