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
    factory :adding_problem do
      sequence(:title) {|n| "Adding problem #{n}" }
      statement "Read two integers from input and output the sum."
      input "add.in"
      output "add.out"
      memory_limit 30
      time_limit 1
      test_sets { [FactoryGirl.build(:test_set, :test_cases => [FactoryGirl.build(:test_case, :input => "5 9", :output => "14")]), \
                   FactoryGirl.build(:test_set, :test_cases => [FactoryGirl.build(:test_case, :input => "100 -50", :output => "50")]), \
                   FactoryGirl.build(:test_set, :test_cases => [FactoryGirl.build(:test_case, :input => "1235 942", :output => "2177")]), \
                   FactoryGirl.build(:test_set, :test_cases => [FactoryGirl.build(:test_case, :input => "-4000 123", :output => "-3877")])] }
      factory :adding_problem_stdio do
        input nil
        output nil
      end
    end
  end
end
