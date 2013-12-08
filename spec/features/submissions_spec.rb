require 'spec_helper'

feature 'submission' do
  scenario 'submit code for a problem' do
    @problem = FactoryGirl.create(:adding_problem)
    @problem_set = FactoryGirl.create(:problem_set, :problems => [@problem], :group_ids => [0])
    login_as users(:user), :scope => :user

    visit submit_problem_path(@problem)
    
    expect do
      within '#new_submission' do
        select LanguageGroup.find_by_identifier("c++").current_language.id, :from => 'submission_language_id'
        attach_file 'submission_source_file', Rails.root.join('spec/fixtures/files/adding.cpp')
        click_on 'Submit'
      end
    end.to change{users(:user).submissions.count}.by(1)
  end
end
