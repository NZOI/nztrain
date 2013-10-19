# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if !(User.exists?(0)) # code in this block to be fixed
  #rootuser = User.new()
  #rootuser.id = 0
  #rootuser.name = "System"
  #rootuser.username = "system"
  #rootuser.email = "system@nztrain.com"
  #rootuser.encrypted_password = ""
  #rootuser.save
  # no users in user table, create a user
  #rootuser = User.new({:id => 0, :name => "Root User", :username => "root", :email => "root@nztrain.com", :encrypted_password => "Need an encrypted password here"})
end

["superadmin","admin","staff","organiser","author"].each do |role|
  Role.find_or_create_by_name(role)
end

# give superadmin status to set everything up
rootuser = nil

if User.exists?(0)
  rootuser = User.find(0) # if a root user exists and is zeroth (this is for security because normally users get positive integers as id) user in users table, give superadmin status
end

if rootuser && rootuser.username == "root"
  superadmin = Role.find_by_name("superadmin")
  superadmin.users.push(rootuser) unless superadmin.users.include?(rootuser);
end

["recaptcha/public_key","recaptcha/private_key"].each do |setting|
  Setting.find_or_create_by_key(setting)
end

# create a special group called Everyone
if !(Group.exists?(0))
  everyone = Group.new()
  everyone.id = 0;
  everyone.name = "Everyone"
  everyone.owner_id = 0
  everyone.save
end

if !(User.exists?(0))
  everyone = Group.find(0);
  user = User.new()
  user.id = 0;
  user.username = "System"
  user.name = "System"
  user.email = "nztrain@gmail.com"
  user.password = "somepassword" # ensure validation succeeds
  user.encrypted_password = "$2a$10$KpSeaHGXoXEwdrERTFVCPo428a2s2r4ZazR999X9abc22368nneen" # set password hash so no known password matches the hash
  user.groups.push(everyone)
  user.save
end

languages = [{:name => "C++", :compiler => "/usr/bin/g++", :interpreted => false},
             {:name => "Python", :compiler => "/usr/bin/python", :interpreted => true},
             {:name => "Haskell", :compiler => "/usr/bin/ghc --make", :interpreted => false},
             {:name => "C", :compiler => "/usr/bin/gcc", :interpreted => false}]
languages.each do |language|
  Language.where(:name => language[:name]).first_or_create!(
    :compiler => language[:compiler],
    :is_interpreted => language[:interpreted]);
end

