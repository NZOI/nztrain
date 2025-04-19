require "spec_helper"

describe EvaluatorsController do
  let(:evaluator) { FactoryBot.create(:evaluator) }

  before do
    sign_in user
  end

  context "as admin" do
    let(:user) { FactoryBot.create(:admin) }

    can_index :evaluators
    can_create :evaluator, attributes: {name: "A unique name", description: "Unique description", source: "special sauce"}
    can_manage :evaluator, attributes: {name: "A unique name", description: "Unique description", source: "special sauce"}
  end

  context "as a normal user" do
    let(:user) { FactoryBot.create(:user) }

    it "can't be accessed" do
      get :index
      expect(response).to have_http_status(:forbidden)
    end
  end
end
