require 'spec_helper'

describe EvaluatorsController do
  before(:all) do
    @evaluator = FactoryGirl.create(:evaluator)
  end
  after(:all) do
    @evaluator.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :evaluators
    can_create :evaluator, :attributes => { :name => "A unique name", :description => "Unique description", :source => "special sauce" }
    can_manage :evaluator, :attributes => { :name => "A unique name", :description => "Unique description", :source => "special sauce" }
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
  end
end
