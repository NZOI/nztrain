module RequestsSpecHelper
  include Warden::Test::Helpers
  def self.included(base)
    base.send :before, :all do
      Warden.test_mode!
    end
    base.send :after, :each do
      Warden.test_reset!
    end
  end
end
