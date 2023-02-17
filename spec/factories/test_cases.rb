# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :test_case do
    sequence(:name) {|n| "Test Case #{n}" }
    input { "Input" }
    output { "Output" }
  end
end
