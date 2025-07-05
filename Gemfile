source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby ">= 2.4.10", "< 2.5"

gem "rails", "~> 5.0.7.2"

gem "devise", "~> 4.0"
gem "psych", "~> 2.0.2" # part of stdlib, need newer version for safe_load

gem "rubyzip", "1.3.0"

gem "superfish-rails", "~> 1.6.0"

gem "nokogiri", "~> 1.10.10"
gem "redcarpet"
gem "rmagick"
gem "carrierwave", "1.3.2"
gem "will_paginate"
gem "has_scope"
gem "pundit", "~> 1.1.0"
gem "recaptcha", require: "recaptcha/rails"
gem "loofah", "<= 2.20.0"
gem "whenever", require: false # for cron jobs
gem "tilt"
gem "simple-navigation", "3.11.0"
gem "simple_form", "3.3.1"
gem "render_anywhere"
gem "pygments.rb", "~> 2.0"
gem "ranked-model"
gem "pdf-reader"
gem "mechanize"
gem "prawn"
gem "rqrcode"
gem "pdfkit"
gem "responders"

gem "countries"
gem "country_select"
gem "world-flags"
gem "ruby-duration"

gem "pg"
gem "backup"

gem "activemodel-serializers-xml"

# Redis and Background Processing
gem "redis"
gem "qless", github: "Shopify/qless"
gem "connection_pool"
gem "sinatra"

# Deploy with Capistrano
# gem 'capistrano'

# Monitoring
gem "newrelic_rpm"
gem "simplecov", require: false
gem "sentry-rails"

# Remove once on ruby >= 2.6
gem "bigdecimal", "< 2.0"

group :development do
  gem "better_errors"
  gem "binding_of_caller"

  gem "foreman"
  gem "spring"
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem "rspec-rails", "~> 3.0"
  gem "capybara"
  gem "capybara-email"

  gem "factory_bot_rails"

  gem "byebug"

  gem "standard"

  gem "rails-controller-testing", "~> 1.0"
end

# Gems used only for assets and not required
# in production environments by default.
# group :assets do
gem "uglifier", ">=1.0.3"
# Provide a JS runtime to execjs without needing to
# have node, bun, or similar installed on the relevant
# server. We should write this out asap, along with the
# rest of the gems in this assets category, as bundling
# a version of libv8 into a rubygem is just security-vuln
# city, but hey, what can you do.
gem "mini_racer", "~> 0.4.0"
gem "yui-compressor"
# end
