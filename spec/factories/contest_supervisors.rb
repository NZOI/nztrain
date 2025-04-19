# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contest_supervisor, class: "ContestSupervisors" do
    contest_id { 1 }
    user_id { 1 }
    site_type { "MyString" }
    site_id { 1 }
  end
end
