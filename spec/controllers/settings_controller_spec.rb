require "spec_helper"

describe SettingsController do
  let(:setting) { FactoryBot.create(:setting) }

  before do
    sign_in user
  end

  context "as superadmin" do
    let(:user) { FactoryBot.create(:superadmin) }

    can_index :settings
    can_create :setting, attributes: {key: "A unique name", value: "Secret value setting"}
    can_manage :setting, attributes: {key: "A unique name", value: "Secret value setting"}
  end

  context "as a normal user" do
    let(:user) { FactoryBot.create(:user) }

    it "doesn't display" do
      get :index
      expect(response).to have_http_status(:forbidden)
    end
  end
end
