# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contest_supervisor, class: "ContestSupervisor" do
    association :contest
    association :user
    association :site, factory: :school
  end
end
