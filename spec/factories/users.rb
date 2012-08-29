# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user, :aliases => [:owner] do
    name "Name of User"
    sequence(:username) {|n| "user#{n}" }
    email { "#{username}@test.emails.com" }
    password "default password"
    confirmed_at "2012-08-05 07:00:38.285779"
    confirmation_sent_at "2012-08-05 07:00:15.772942"

    factory :admin do
      roles { [Role.find_by_name("admin")] }
    end
    factory :superadmin do
      roles { [Role.find_by_name("superadmin")] }
    end
  end
end
