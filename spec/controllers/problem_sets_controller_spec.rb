require "spec_helper"

describe ProblemSetsController do
  let(:problem_set) { FactoryBot.create(:problem_set) }

  before do
    sign_in user
  end

  context "as admin" do
    let(:user) { FactoryBot.create(:admin) }

    can_index :problem_sets
    can_create :problem_set, attributes: {name: "A unique title"}
    can_manage :problem_set, attributes: {name: "A unique title"}
  end

  context "as an organiser" do
    let(:user) { FactoryBot.create(:organiser) }

    can_index :problem_sets, params: {filter: "my"}
  end
end
