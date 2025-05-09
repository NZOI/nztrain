# db/seeds/common.rb always runs before this, so we can assume
# roles etc defined there exist already.

# Add a nice, memorable, boring set of users for local development
%w[user admin superadmin].each do |username|
  User
    .create_with(
      name: username.capitalize,
      email: "#{username}@example.com",
      password: "password",
      confirmed_at: Time.current
    ).find_or_create_by!(
      username: username
    )
end

User.find_by!(username: "admin").update!(roles: [Role.find_by!(name: "admin")])
User.find_by!(username: "superadmin").update!(roles: [Role.find_by!(name: "superadmin")])

# A problem & set
problem_set = ProblemSet.find_or_create_by!(name: "Example problems")
Problem
  .create_with(problem_sets: [problem_set])
  .find_or_create_by!(name: "Example problem")

problem_set.group_associations.find_or_create_by!(group: Group.find_by(name: "Everyone"))
