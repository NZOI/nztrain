# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# We use different seed files for different environments, meaning we don't
# have to worry about development data leaking into prod (in the unlikely
# event we ever ran db:seed in prod), and vice-vesa.

# db/seeds/common.rb is things we want in every environment
require_relative Rails.root.join("db/seeds/common")

env_seed_path = Rails.root.join("db/seeds/#{Rails.env}.rb")
require_relative env_seed_path if File.exist?(env_seed_path)
