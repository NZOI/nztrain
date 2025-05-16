require "spec_helper"

describe ContestSupervisor do
  subject(:contest_supervisor) { FactoryBot.create(:contest_supervisor, contest: contest) }

  let(:contest) { FactoryBot.create(:contest) }

  describe "#potential_contestants" do
    let!(:students) do
      10.times.map {
        FactoryBot.create(:user, country_code: "NZ", school: contest_supervisor.site)
      }
    end

    context "when no-one is registered for the contest" do
      it "includes all the students at the school" do
        expect(contest_supervisor.potential_contestants).to match_array(students)
      end
    end

    context "when some people are registered for the contest" do
      before do
        students.take(5).each do |student|
          contest.registrants << student
        end
      end

      it "includes the remaining students at the school" do
        expect(contest_supervisor.potential_contestants).to match_array(students.drop(5))
      end
    end

    context "when no-one is registered for the contest" do
      before do
        students.each do |student|
          contest.registrants << student
        end
      end

      it "return an empty list" do
        expect(contest_supervisor.potential_contestants).to be_empty
      end
    end
  end
end
