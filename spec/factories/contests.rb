# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contest do
    sequence(:name) { |n| "Contest #{n}" }
    start_time { "2012-01-01 08:00:00" }
    end_time { "2012-01-01 18:00:00" }
    finalized_at { nil }
    duration { 5.0 }
    problem_set_id { 0 }
    owner_id { 0 }
  end
end
