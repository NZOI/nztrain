# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contest_relation do
    user_id 0
    contest_id 0
    started_at { |rel| rel.contest.try(:start_time) || "2012-01-01 12:00:00" }
  end
end
