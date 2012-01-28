source 'http://rubygems.org'

gem 'devise', '1.4.2'
gem 'rails', '3.0.8' # if upgraded, remove monkey patch in application_helper.rb > escape_javascript()

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

gem 'rubyzip', :require => 'zip/zip'

gem 'jquery-rails', '>= 1.0.12'

gem "bluecloth"
gem "albino"
gem "nokogiri"
gem 'rails_markitup'
gem 'will_paginate'
gem 'has_scope'
gem 'cancan'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'squeel' # (NEW GEM) use lightly - only using in ability.rb, until it is more established (Jan 2012)  ---------> supersedes meta_where
gem 'meta_where' # required to get .outer in ability.rb working

gem 'pg'
# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'


# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'webrat'

  # To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
  gem 'ruby-debug'
  # gem 'ruby-debug19', :require => 'ruby-debug'
end
