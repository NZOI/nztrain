# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :school do
    sequence(:name) { |n| "School #{n}" }
  end
end
