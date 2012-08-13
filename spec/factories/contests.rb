# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contest do
    sequence(:title) {|n| "Contest #{n}" }
    start_time "2012-01-01 08:00:00"
    end_time "2012-01-01 18:00:00"
    duration 5.0
    problem_set_id 0
    owner_id 0
  end
end
