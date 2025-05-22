require "spec_helper"

RSpec.describe SubmissionsController, type: :request do
  let(:problem) { FactoryBot.create(:problem) }
  let(:problem_set) { FactoryBot.create(:problem_set, problems: [problem]) }
  let(:user) { FactoryBot.create(:user, groups: [group]) }
  let(:group) { FactoryBot.create(:group) }
  let!(:submission) { FactoryBot.create(:submission, problem: problem, user: user) }

  before do
    problem_set.groups << group

    sign_in(user)
  end

  describe "GET /problems/:id/submissions" do
    it "doesn't explode" do
      get submissions_problem_path(problem)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /submissions/my" do
    context "when not in an active contest" do
      it "doesn't explode" do
        get my_submissions_path

        expect(response).to have_http_status(:success)
      end
    end

    context "when in an active contest" do
      let(:contest) { FactoryBot.create(:contest, problem_set: problem_set) }
      let!(:contest_relation) { FactoryBot.create(:contest_relation, user: user, contest: contest, finish_at: 99.years.from_now) }

      it "doesn't explode" do
        get my_submissions_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
