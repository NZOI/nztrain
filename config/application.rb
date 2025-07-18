require File.expand_path("../boot", __FILE__)
require "rubygems"
require "rails/all"

if defined?(Bundler)
  # Require the gems listed in Gemfile, including any gems
  # you've limited to :test, :development, or :production.
  Bundler.require(:default, Rails.env)
end

module NZTrain
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W[#{Rails.root}/lib]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Auckland"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("fonts")
    config.assets.precompile += %w[submission.css]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = "1.0"

    config.action_mailer.default_url_options = {host: "train.nzoi.org.nz", protocol: "https"}
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true

    ActionMailer::Base.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      authentication: :plain,
      domain: "nzoi.org.nz",
      #:user_name => ..., # set in config/initializers/mailer.rb
      #:password => ...,  # set in config/initializers/mailer.rb
      enable_starttls_auto: true
    }

    config.middleware.use PDFKit::Middleware, {}, only: [%r{^/item/[0-9]*/label}]
  end
end
