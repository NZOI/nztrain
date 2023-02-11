# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :problem do
    sequence(:name) {|n| "Problem #{n}" }
    statement { "Do nothing" }
    sequence(:input) {|n| "#{n}.in" }
    sequence(:output) {|n| "#{n}.out"}
    memory_limit { 1 }
    time_limit { 1 }
    owner_id { 0 }
    factory :adding_problem do
      sequence(:name) {|n| "Adding problem #{n}" }
      statement { "Read two integers from input and output the sum." }
      input { "add.in" }
      output { "add.out" }
      memory_limit { 30 }
      time_limit { 1 }
      test_cases { [FactoryBot.create(:test_case, :input => "5 9", :output => "14"),
                    FactoryBot.create(:test_case, :input => "100 -50", :output => "50"),
                    FactoryBot.create(:test_case, :input => "1235 942", :output => "2177"),
                    FactoryBot.create(:test_case, :input => "-4000 123", :output => "-3877")] }
      test_sets { (0...4).map{FactoryBot.create(:test_set)} }

      after(:create) do |problem|
        (0...4).each do |i|
          FactoryBot.create(:test_case_relation, :test_case => problem.test_cases[i], :test_set => problem.test_sets[i])
        end
      end

      factory :adding_problem_stdio do
        input { nil }
        output { nil }
      end
    end
  end
end
