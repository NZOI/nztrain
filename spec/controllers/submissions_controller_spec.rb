require 'spec_helper'

describe SubmissionsController do
  before(:all) do
    @submission = FactoryBot.create(:submission, :problem => problems(:problem), :user => users(:superadmin))
  end
  after(:all) do
    @submission.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :submissions
    can_show :submission
    can_destroy :submission
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
    can_index :submissions, :params => { :filter => 'my' }
  end
end
