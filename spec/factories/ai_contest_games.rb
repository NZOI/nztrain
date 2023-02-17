# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :ai_contest_games do
    ai_contest_id { 1 }
    ai_submission_2_id { 1 }
    ai_submission_1_id { 1 }
    record { "MyText" }
    score_1 { 1 }
    score_2 { 1 }
  end
end
