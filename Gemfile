source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 4.0.0'

gem 'nzic_models', github: 'NZOI/nzic_models'
#gem 'nzic_models', path: '../../nzic/nzic_models'

gem 'devise', '~> 3.2.2'
gem 'psych', '~> 2.0.2' # part of stdlib, need newer version for safe_load

# change back to cookie-based store (encrypted)
gem 'activerecord-session_store'

gem 'rubyzip', '1.3.0'

gem 'jquery-rails', '~> 3.1.3'
gem 'jquery-ui-rails', '4.0.5'
gem 'jquery-historyjs', '0.2.3'
gem 'superfish-rails', '~> 1.6.0'

gem 'forem', github: 'radar/forem', branch: 'rails4'
gem 'forem-redcarpet', github: 'NZOI/forem-redcarpet'

gem "nokogiri", '~> 1.10.8'
gem 'redcarpet'
#gem 'rmagick', '2.13.2'
gem 'rmagick'
gem 'carrierwave', '0.9.0'
gem 'will_paginate'
gem 'has_scope'
gem 'pundit', '0.2.1'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'loofah'
gem 'whenever', :require => false # for cron jobs
gem 'squeel'#, '~> 1.1.1' # until version 1.1.2 released
gem 'tilt'
gem 'simple-navigation', '3.11.0'
gem 'simple_form', '3.0.1'
gem 'facebox-rails'
gem 'strong_presenter', '~> 0.2.2'
gem 'render_anywhere'
gem 'pygments.rb', '0.5.4'
gem 'ranked-model', :github => 'mixonic/ranked-model'
gem 'pdf-reader'
gem 'mechanize'
gem 'prawn'
gem 'rqrcode'
gem 'pdfkit'

gem 'countries'
gem 'country_select'
gem 'geocoder'
gem 'hive_geoip2'
gem 'world-flags'
gem 'jquery-final_countdown-rails'
gem 'ruby-duration'

gem 'pg'
gem 'backup'

# Redis and Background Processing
gem 'redis', '< 4.0'
gem 'rake', '< 11.0' # pinned to avoid last_comment issue
gem 'qless'#, :github => 'ronalchn/qless', :branch => 'nztrain'
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
  gem 'rspec-rails', '~> 3.0'
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



