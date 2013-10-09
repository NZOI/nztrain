module AbilitySpecHelper
  class AuthorizationTestHelper
    include Test::Unit::Assertions
    include Authorization::TestHelper
  end
  testhelper = AuthorizationTestHelper.new

  User.send :define_method, 'should_be_permitted_to' do |actions,subjects|
    testhelper.with_user self do
      Array(actions).each do |action|
        Array(subjects).each do |subject|
          testhelper.should_be_allowed_to action, subject
        end
      end
    end
  end

  User.send :define_method, 'should_not_be_permitted_to' do |actions,subjects|
    testhelper.with_user self do
      Array(actions).each do |action|
        Array(subjects).each do |subject|
          testhelper.should_not_be_allowed_to action, subject
        end
      end
    end
  end
end
