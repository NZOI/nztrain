# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contest_score do
    user_id 0
    contest_relation_id 0
    problem_id 0
    score 0
    attempts 0
    attempt 0
    submission_id 0
  end
end
