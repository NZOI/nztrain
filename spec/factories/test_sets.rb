# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_set do
    sequence(:name) {|n| "Test Set #{n}" }
    points 1
    problem_id 0
  end
end
