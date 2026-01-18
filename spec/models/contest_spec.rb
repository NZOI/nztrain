require "spec_helper"

describe Contest do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user) }
  let(:contest) { FactoryBot.create(:contest, duration: 3) }
  let(:relation) { ContestRelation.create!(contest: contest, user: user) }

  context "when the contest end_time is updated" do
    context "when the contest can be completed within the window" do
      before do
        travel_to contest.start_time + 5.minutes

        relation.start!
      end

      it "doesn't update contest_relation#finish_at" do
        expect {
          contest.update!(end_time: contest.end_time + 1.hour)
        }.not_to change {
          relation.reload.finish_at
        }
      end
    end

    context "when the competitor started late and has a shortened window" do
      before do
        travel_to contest.end_time - 1.hour

        relation.start!
      end

      context "when the contest is extended by a small amount" do
        it "updates contest_relation#finish_at" do
          expect {
            contest.update!(end_time: contest.end_time + 1.hour)
          }.to change {
            relation.reload.finish_at
          }.by(1.hour)
        end
      end

      context "when the contest is extended by a huge amount" do
        it "updates contest_relation#finish_at to the maximum duration" do
          expect {
            contest.update!(end_time: contest.end_time + 10.weeks)
          }.to change {
            relation.reload.finish_at
          }.by(2.hours)
        end
      end
    end
  end

  context "when the contest can be completed within the window" do
    before do
      travel_to contest.start_time + 5.minutes
    end

    context "when the contest duration is increased" do
      before do
        relation.start!
      end

      it "gives the competitor more time" do
        expect {
          contest.update!(duration: 7)
        }.to change {
          relation.reload.finish_at
        }.by(4.hours)
      end
    end

    context "when the contest duration is decreased" do
      before do
        relation.start!
      end

      it "gives the competitor less time" do
        expect {
          contest.update!(duration: 2)
        }.to change {
          relation.reload.finish_at
        }.by(-1.hours)
      end
    end
  end

  context "when the competitor started late and has a shortened window" do
    before do
      travel_to contest.end_time - 1.hour

      relation.start!
    end

    context "when the contest duration is increased" do
      it "gives the competitor no additional time" do
        expect {
          contest.update!(duration: 10.hours)
        }.not_to change {
          relation.reload.finish_at
        }
      end
    end

    context "when the contest duration is decreased" do
      it "gives the competitor no additional time" do
        expect {
          contest.update!(duration: 3.hours)
        }.not_to change {
          relation.reload.finish_at
        }
      end
    end
  end

  context "when the competitor started late but has full time" do
    before do
      travel_to contest.end_time - 4.hour

      relation.start!
    end

    context "when the contest duration is increased" do
      it "gives the competitor more time, but not the full duration" do
        expect {
          contest.update!(duration: 10.hours)
        }.to change {
          relation.reload.finish_at
        }.by(1.hour)
      end
    end
  end
end
