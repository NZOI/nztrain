source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 2.3.8', '< 2.4' # must be < 2.4 until we upgrade to Rails >= 4.2.8 (see https://rubyonrails.org/2017/2/21/Rails-4-2-8-has-been-released)

gem 'rails', '4.1.16'
gem 'json_cve_2020_10663', '~> 1.0' # required until we update json >= 2.3, which we can only do once we upgrade to Rails >= 4.2 because activesupport 4.1.* depends on json ~> 1.7 (i.e < 2.0): https://rubygems.org/gems/activesupport/versions/4.1.16

gem 'devise', '~> 3.2.2'
gem 'psych', '~> 2.0.2' # part of stdlib, need newer version for safe_load

# change back to cookie-based store (encrypted)
gem 'activerecord-session_store'

gem 'rubyzip', '1.3.0'

gem 'jquery-rails', '~> 3.1.3'
gem 'jquery-ui-rails', '4.0.5'
gem 'jquery-historyjs', '0.2.3'
gem 'superfish-rails', '~> 1.6.0'

gem 'nokogiri', '~> 1.10.10'
gem 'redcarpet'
gem 'rmagick'
gem 'carrierwave', '1.3.2'
gem 'will_paginate'
gem 'has_scope'
gem 'pundit', '0.2.1'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'loofah'
gem 'whenever', :require => false # for cron jobs
gem 'squeel'#, '~> 1.1.1' # until version 1.1.2 released
gem 'tilt'
gem 'simple-navigation', '3.11.0'
gem 'simple_form', '3.2.1'
gem 'facebox-rails'
gem 'strong_presenter', '~> 0.2.2'
gem 'render_anywhere'
gem 'pygments.rb', '~> 1.1.0'
gem 'ranked-model', '< 0.4.3' # pinned because 0.4.3-0.4.4 are broken (see https://github.com/brendon/ranked-model/issues/139; we also need the fix in https://github.com/brendon/ranked-model/pull/152); we can't update to 0.4.5 yet because it requires activerecord >= 4.2
gem 'pdf-reader'
gem 'mechanize'
gem 'prawn'
gem 'rqrcode'
gem 'pdfkit'

gem 'countries'
gem 'country_select'
gem 'world-flags'
gem 'jquery-final_countdown-rails'
gem 'ruby-duration'

gem 'pg'
gem 'backup'

# Redis and Background Processing
gem 'redis', '< 4.0'
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

  gem 'factory_bot_rails'

  gem 'byebug'

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
