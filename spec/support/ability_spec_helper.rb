module AbilitySpecHelper
  RSpec::Matchers.define :be_permitted_to do |actions,subjects|
    match do |user|
      begin
        Array(actions).each do |action|
          Array(subjects).each do |subject|
            message = lambda { "Expected #{user.username} (roles: [#{user.roles.pluck(:name).join(", ")}]) to be permitted to #{action} #{subject}" }
            expect(Pundit.policy!(user, subject).public_send("#{action}?")).to be(true), message
          end
        end
        true
      rescue RSpec::Expectations::ExpectationNotMetError => exception
        @exception = exception
        false
      end
    end
    match_when_negated do |user|
      begin
        Array(actions).each do |action|
          Array(subjects).each do |subject|
            message = lambda { "Expected #{user.username} (roles: [#{user.roles.pluck(:name).join(", ")}]) not to be permitted to #{action} #{subject}" }
            expect(Pundit.policy!(user, subject).public_send("#{action}?")).to be(false), message
          end
        end
        true
      rescue RSpec::Expectations::ExpectationNotMetError => exception
        @exception = exception
        false
      end
    end
    failure_message do |user|
      @exception.message
    end
    failure_message_when_negated do |user|
      @exception.message
    end
  end
end
