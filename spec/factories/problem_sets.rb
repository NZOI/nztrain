# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :problem_set do
    sequence(:name) {|n| "Problem Set #{n}" }
    owner_id 0
  end
end
