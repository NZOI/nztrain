# This files provides test/unit/assertions for rspec-rails <3.2.0 by
# aliasing Test::Unit::Assertions to MiniTest::Assertions.
# When rspec-rails is updated to 3.2.0+ this file should be removed.
#
# test/unit/assertions was removed from ruby-core in 2.2.0 (https://bugs.ruby-lang.org/issues/9711).
# rspec-rails <3.2.0 doesn't handle the removal on rails 4.0.x (fixed in https://github.com/rspec/rspec-rails/pull/1264).
require 'active_support/deprecation'
ActiveSupport::Deprecation.warn 'This file should be removed when rspec-rails is updated to 3.2.0+'

require 'minitest/unit'

module Test
  module Unit
    Assertions = MiniTest::Assertions
  end
end
