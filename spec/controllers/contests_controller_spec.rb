require "spec_helper"

describe ContestsController do
  let(:problem_set) { FactoryBot.create(:problem_set) }
  let(:contest) { FactoryBot.create(:contest, problem_set: problem_set) }

  context "as admin" do
    before do
      sign_in FactoryBot.create(:admin)
    end

    can_index :contests
    can_index :contests, params: {filter: "my"}

    can_create :contest, attributes: {name: "A unique title", start_time: "2012-01-01 08:00:00", end_time: "2012-01-01 18:00:00", duration: 5.0}
    can_manage :contest, attributes: {name: "A unique title", start_time: "2012-01-01 08:00:00", end_time: "2012-01-01 18:00:00", duration: 5.0}
  end

  context "as an organiser" do
    before do
      sign_in FactoryBot.create(:organiser)
    end

    can_index :contests, params: {filter: "my"}
  end
end
