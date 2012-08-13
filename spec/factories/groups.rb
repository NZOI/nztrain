# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    sequence(:name) {|n| "Group #{n}" }
    owner_id 0
  end
end
