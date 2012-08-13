module FixturesSpecHelper
  @@users={}
  def self.users=(users)
    @@users=users
  end
  def self.users
    @@users
  end
  def users(user)
    @@users[user]
  end
end

