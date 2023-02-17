# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :evaluator do
    sequence(:name) {|n| "Evaluator #{n}" }
    description { "Evaluator description" }
    source { "Shell source code" }
    owner_id { 0 }
  end
end
