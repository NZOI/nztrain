require "spec_helper"

RSpec.describe ContestRelationsController, type: :request do
  let(:student) { FactoryBot.create(:user) }
  let(:user) { FactoryBot.create(:superadmin) }
  let(:contest) { FactoryBot.create(:contest) }
  let(:school) { FactoryBot.create(:school) }
  let!(:contest_relation) { FactoryBot.create(:contest_relation, user: student, school: school, contest: contest) }

  before do
    sign_in(user) if user
  end

  describe "DELETE /contest_relations/:id" do
    context "when not signed in" do
      let(:user) { nil }

      context "when the relation exists" do
        it "doesn't remove the relation" do
          expect { delete "/contest_relations/#{contest_relation.id}" }
            .not_to change { contest.reload.contest_relations.count }
        end

        it "redirects to login page" do
          delete "/contest_relations/#{contest_relation.id}"
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "when the relation doesn't exist" do
        let(:contest_relation) { nil }

        it "redirect to login page" do
          delete "/contest_relations/1"
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    context "when signed in as a superadmin" do
      let(:user) { FactoryBot.create(:superadmin) }

      context "when the relation exists" do
        it "removes the relation" do
          expect { delete "/contest_relations/#{contest_relation.id}" }
            .to change { contest.reload.contest_relations.count }
            .from(1).to(0)
        end
      end

      context "when the relation doesn't exist" do
        let(:contest_relation) { nil }

        it "raises an exception" do
          expect { delete "/contest_relations/1" }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe "POST /contest_relations/:id/update_year_level" do
    context "when signed in a supervisor of this contest" do
      let(:user) { FactoryBot.create(:user) }

      before do
        contest.contest_supervisors.create!(user: user, site: school)
      end

      context "when selecting a year level between 1-13" do
        it "updates the year level" do
          expect {
            post "/contest_relations/#{contest_relation.id}/update_year_level", {year_level: 12}
          }
            .to change { contest_relation.reload.school_year }
            .from(nil).to(12)
        end
      end
    end
  end
end
