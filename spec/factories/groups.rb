# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :group do
    sequence(:name) {|n| "Group #{n}" }
    owner_id { 0 }
  end
end
