# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :setting do
    sequence(:key) {|n| "Setting #{n}" }
    value { "value" }
  end
end
