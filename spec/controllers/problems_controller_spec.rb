require 'spec_helper'

describe ProblemsController do
  before(:all) do
    @group = FactoryGirl.create(:group, :name => "Special Group", :members => [users(:admin),users(:user)])
    @group_set = FactoryGirl.create(:problem_set, :name => "Set in Group", :groups => [@group])
    @group_problem = FactoryGirl.create(:adding_problem, :problem_sets => [@group_set])
  end
  after(:all) do
    [@group, @group_set, @group_problem].reverse_each { |object| object.destroy }
  end
  shared_examples "for any user" do
    can_index :problems, :params => { :filter => 'my' }
    can_create :problem, :attributes => { :name => "A unique title", :statement => "A unique statement" }
    can_manage :owned_problem, :resource_name => :problem, :attributes => { :name => "A unique title", :statement => "A unique statement" }
  end

  context "as admin" do
    before(:all) do
      @owned_problem = FactoryGirl.create(:problem, :owner => users(:admin))
      @unowned_problem = FactoryGirl.create(:problem)
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
      @owned_problem = FactoryGirl.create(:problem, :owner => users(:user))
      @unowned_problem = FactoryGirl.create(:problem)
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
      expect(response).to be_success
    end

    it 'can post submit for group problem' do
      expect_any_instance_of(Submission).to receive(:judge)
      # post multi-part form
      post :submit, :id => @group_problem.id, :submission => { :language_id => LanguageGroup.find_by_identifier("c++").current_language, :source_file => fixture_file_upload('/files/adding.cpp', 'text/plain') }
      expect(response).to redirect_to submission_path(assigns(:submission))
      expect(assigns(:submission).problem_id).to eq(@group_problem.id)
      expect(assigns(:submission).user_id).to eq(users(:user).id)
      expect(assigns(:submission).language.group.identifier).to eq('c++')
      expect(assigns(:submission).source).not_to be_empty
    end
  end
end
