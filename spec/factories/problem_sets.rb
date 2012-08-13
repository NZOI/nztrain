# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :problem_set do
    sequence(:title) {|n| "Problem Set #{n}" }
    owner_id 0
  end
end
