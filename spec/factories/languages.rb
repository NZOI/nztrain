# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :language do
    name { "MyString" }
    compiler { "MyString" }
    is_interpreted { false }
  end
end
