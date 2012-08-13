# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :submission do
    source "sauce"
    language "C++"
    score 100
    user_id 0
    problem_id 0
    created_at { Time.now }
    updated_at { created_at }
    judge_output "Judge"
    debug_output "Debug"
  end
end
