# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :ai_contest do
    name { "MyString" }
    start_time { "2013-01-07 14:51:43" }
    end_time { "2013-01-07 14:51:43" }
    owner_id { "" }
    finalized_at { "2013-01-07 14:51:43" }
    sample_ai { "MyText" }
    statement { "MyText" }
    judge { "MyString" }
  end
end
