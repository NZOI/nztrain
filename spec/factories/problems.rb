# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :problem do
    sequence(:title) {|n| "Problem #{n}" }
    statement "Do nothing"
    sequence(:input) {|n| "#{n}.in" }
    sequence(:output) {|n| "#{n}.out"}
    memory_limit 1
    time_limit 1
    owner_id 0
    #problem.after_create { |p| p.owner <<  }
  end
end
