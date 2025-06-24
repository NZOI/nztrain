# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contest_score do
    contest_relation_id { 0 }
    problem_id { 0 }
    score { 0 }
    attempts { 1 }
    attempt { 1 }
    submission_id { 0 }
  end
end
