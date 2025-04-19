require "spec_helper"

describe TestCasesController do
  before { pending }
  before(:all) do
    @test_case = FactoryBot.create(:test_case, problem_id: test_sets(:test_set).problem_id)
    TestCaseRelation.create(test_set: test_sets(:test_set), test_case: @test_case)
  end
  after(:all) do
    @test_case.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :test_cases, params: {problem_id: proc { problems(:problem) }}
    # can_manage :test_case, :attributes => { :name => "A unique name", :input => "Some secret judging data", :output => "The unguessable answer" }
    can_show :test_case
    can_destroy :test_case
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
  end
end
