# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
  end
end
