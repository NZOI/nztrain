source 'http://rubygems.org'

gem 'devise', '~> 3.2.2'
gem 'rails', '~> 4.0.0'

gem 'psych', '~> 2.0.2' # part of stdlib, need newer version for safe_load

# change back to cookie-based store (encrypted)
gem 'activerecord-session_store'

gem 'rubyzip'

gem 'jquery-rails', '~> 3.0.4'
gem 'jquery-ui-rails'
gem 'jquery-historyjs'
gem 'superfish-rails'

gem "nokogiri"
gem 'redcarpet'
gem 'rmagick'
gem 'carrierwave'
gem 'will_paginate'
gem 'has_scope'
gem 'pundit'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'loofah'
gem 'whenever', :require => false # for cron jobs
gem 'squeel', :github => 'activerecord-hackery/squeel' # until version 1.1.2 released
gem 'tilt'
gem 'simple-navigation'
gem 'simple_form'
gem 'facebox-rails'
gem 'strong_presenter', '~> 0.2.2'
gem 'render_anywhere'
gem 'pygments.rb'
gem 'ranked-model', :github => 'mixonic/ranked-model'

gem 'pg'
gem 'backup'

# Use unicorn as the web server
gem 'unicorn'

# Redis and Background Processing
gem 'redis'
gem 'qless', :github => 'ronalchn/qless', :branch => 'nztrain'
gem 'connection_pool'
gem 'sinatra'

# Deploy with Capistrano
# gem 'capistrano'

# Monitoring
gem 'newrelic_rpm'
gem 'coveralls', require: false

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'foreman'
  gem 'spring'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'capybara'
  gem 'capybara-email'

  gem 'factory_girl_rails'

  gem 'byebug'
  gem 'factory_girl'#, '~> 4.0'

  gem 'ruby_parser' # for declarative_authorization
end


# Gems used only for assets and not required  
# in production environments by default.  
#group :assets do  
gem 'sass'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier', '>=1.0.3'
gem 'libv8', '~> 3.3'
gem 'therubyracer', '~> 0.11' # required for the execjs gem (dependency)
gem 'yui-compressor'
#end



