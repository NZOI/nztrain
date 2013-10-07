source 'http://rubygems.org'

gem 'devise', '~> 2.2.3'
gem 'rails', '~> 3.2.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# delete when upgrading to rails 4.x, commit to allow Rack::Test::UploadedFile
gem 'strong_parameters'#, :git => 'git://github.com/rails/strong_parameters.git', :ref => 'b88ca5be23004de6efeebaf956dd4f8ddb0a23b0'

gem 'rubyzip', :require => 'zip/zip'

gem 'jquery-rails', '~> 3.0.4'
gem 'jquery-ui-rails'
gem 'jquery-historyjs'
gem 'superfish-rails'

gem "bluecloth"
gem "albino"
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
gem 'simple-navigation'#, :git => 'git://github.com/ronalchn/simple-navigation.git', :branch => 'render_navigation.takes.block'
gem 'simple_form'
gem 'facebox-rails'

gem 'pg'
gem 'backup'

# Use unicorn as the web server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# Monitoring
gem 'newrelic_rpm'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

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
  #gem 'webrat'

  gem 'factory_girl_rails'

  # To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
  if RUBY_VERSION.split('.')[0..1]==["1","8"]
    gem 'ruby-debug'
    gem 'factory_girl', '~> 2.0'
  else # ruby 1.9+
    gem 'debugger'
    gem 'factory_girl'#, '~> 4.0'
    # gem 'ruby-debug19', :require => 'ruby-debug'
  end
end


# Gems used only for assets and not required  
# in production environments by default.  
group :assets do  
  gem 'sass'
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>=1.0.3'
  gem 'libv8', '~> 3.3'
  gem 'therubyracer', '~> 0.11.4' # required for the execjs gem (dependency)
  gem 'yui-compressor'
end



