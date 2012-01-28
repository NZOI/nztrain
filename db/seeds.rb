# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

["superadmin","admin","staff","organizer","author"].each do |role|
  Role.find_or_create_by_name(role)
end

# If no users exist in database
  # then create a root superadmin user
#

# give superadmin status to set everything up
# once migrated, change this to add root superadmin user if it was created for new installations
unless Role.find_by_name("superadmin").users.include? (User.find_by_id_and_name(35, "Ronald Chan"))
  Role.find_by_name("superadmin").users.push(User.find_by_id_and_name(35, "Ronald Chan"))
end

["recaptcha/public_key","recaptcha/private_key"].each do |setting|
  Setting.find_or_create_by_key(setting)
end




