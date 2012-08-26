module AbilitySpecHelper
  RSpec::Matchers.define :be_able_to_do_all do |actions,subjects|
    match do |ability|
      Array(actions).all? { |action| Array(subjects).all? { |subject| ability.can? action, subject } }
    end
    failure_message_for_should do |ability|
      action = Array(actions).detect { |action| Array(subjects).detect { |subject| ability.cannot? action, subject } }
      subject = Array(subjects).detect { |subject| ability.cannot? action, subject }
      "expected can? :#{action}, #{subject}, but could not"
    end
    failure_message_for_should_not do |relation|
      "expected at least one cannot? #{actions}, #{subjects}, but was able to do all"
    end
    description do
      "is able to do all actions on all subjects"
    end
  end

  RSpec::Matchers.define :not_be_able_to_do_any do |actions,subjects|
    match do |ability|
      Array(actions).all? { |action| Array(subjects).all? { |subject| ability.cannot? action, subject } }
    end
    failure_message_for_should do |relation|
      action = Array(actions).detect { |action| Array(subjects).detect { |subject| ability.can? action, subject } }
      subject = Array(subjects).detect { |subject| ability.can? action, subject }
      "expected cannot? :#{action}, #{subject}, but could"
    end
    failure_message_for_should_not do |relation|
      "expected at least one can? #{actions}, #{subjects}, but was not able to do any"
    end
    description do
      "is unable to do any actions on any subjects"
    end
  end
end
