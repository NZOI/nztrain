require "spec_helper"

describe SubmissionsController do
  let(:problem) { FactoryBot.create(:problem) }
  let(:user) { FactoryBot.create(:superadmin) }
  let(:submission) { FactoryBot.create(:submission, problem: problem, user: user) }

  before do
    sign_in user
  end

  context "as admin" do
    let(:user) { FactoryBot.create(:admin) }

    can_index :submissions
    can_show :submission
    can_destroy :submission
  end

  context "as a normal user" do
    let(:user) { FactoryBot.create(:user) }

    can_index :submissions, params: {filter: "my"}
  end
end
