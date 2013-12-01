source 'http://rubygems.org'

gem 'devise', '~> 2.2.3'
gem 'rails', '~> 3.2.0'

# delete when upgrading to rails 4.x
gem 'strong_parameters'

gem 'rubyzip'

gem 'jquery-rails', '~> 3.0.4'
gem 'jquery-ui-rails'
gem 'jquery-historyjs'
gem 'superfish-rails'

gem "bluecloth"
#gem "albino" # library is deprecated
gem "nokogiri"
gem 'markitup_rails'
gem 'rmagick'
gem 'carrierwave'
gem 'will_paginate'
gem 'has_scope'
gem 'declarative_authorization'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'loofah'
gem 'whenever', :require => false # for cron jobs
gem 'squeel' # (NEW GEM) use lightly - only using in ability.rb, until it is more established (Jan 2012)  ---------> supersedes meta_where
gem 'tilt'
gem 'simple-navigation'
gem 'simple_form'
gem 'facebox-rails'
gem 'strong_presenter', '~> 0.2.2'

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

  gem 'factory_girl_rails'

  gem 'byebug'
  gem 'factory_girl'#, '~> 4.0'

  gem 'ruby_parser' # for declarative_authorization
end


# Gems used only for assets and not required  
# in production environments by default.  
group :assets do  
  gem 'sass'
  gem 'sass-rails', "  ~> 3.2"
  gem 'coffee-rails', "~> 3.2"
  gem 'uglifier', '>=1.0.3'
  gem 'libv8', '~> 3.3'
  gem 'therubyracer', '~> 0.11' # required for the execjs gem (dependency)
  gem 'yui-compressor'
end



