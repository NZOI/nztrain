require 'spec_helper'

describe ProblemsController do
  before(:all) do
    @group = FactoryBot.create(:group, :name => "Special Group", :members => [users(:admin),users(:user)])
    @group_set = FactoryBot.create(:problem_set, :name => "Set in Group", :groups => [@group])
    @group_problem = FactoryBot.create(:adding_problem, :problem_sets => [@group_set])
  end
  after(:all) do
    [@group, @group_set, @group_problem].each { |object| object.destroy }
  end
  shared_examples "for any user" do
    can_index :problems, :params => { :filter => 'my' }
    can_create :problem, :attributes => { :name => "A unique title", :statement => "A unique statement" }
    can_manage :owned_problem, :resource_name => :problem, :attributes => { :name => "A unique title", :statement => "A unique statement" }
  end

  context "as admin" do
    before(:all) do
      @owned_problem = FactoryBot.create(:problem, :owner => users(:admin))
      @unowned_problem = FactoryBot.create(:problem)
    end
    after(:all) do
      @unowned_problem.destroy
      @owned_problem.destroy
    end
    before(:each) do
      sign_in users(:admin)
    end
    include_examples "for any user"
    can_manage :unowned_problem, :resource_name => :problem, :attributes => { :name => "A unique title", :statement => "A unique statement" }
  end

  context "as a normal user" do
    before(:all) do
      @owned_problem = FactoryBot.create(:problem, :owner => users(:user))
      @unowned_problem = FactoryBot.create(:problem)
    end
    after(:all) do
      @unowned_problem.destroy
      @owned_problem.destroy
    end
    before(:each) do
      sign_in users(:user)
    end
    include_examples "for any user"

    it 'can get submit for group problem' do
      get :submit, :id => @group_problem.id
      response.should be_success
    end

    it 'can post submit for group problem' do
      Submission.any_instance.should_receive(:judge)
      # post multi-part form
      post :submit, :id => @group_problem.id, :submission => { :language_id => LanguageGroup.find_by_identifier("c++").current_language, :source_file => fixture_file_upload('/files/adding.cpp', 'text/plain') }
      response.should redirect_to submission_path(assigns(:submission))
      assigns(:submission).problem_id.should == @group_problem.id
      assigns(:submission).user_id.should == users(:user).id
      assigns(:submission).language.group.identifier.should == 'c++'
      assigns(:submission).source.should_not be_empty
    end
  end
end
