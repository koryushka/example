Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes                             = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load                                = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local               = false
  config.action_controller.perform_caching         = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files                        = ENV['RAILS_SERVE_STATIC_FILES'].present?


  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level                                 = :debug

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { host: 'staging.curagolife.com' }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks                            = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation                = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter                             = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  Devise.setup do |config|
    config.secret_key = '00889083261c354cc2e8106daaeff0cb10e02137cf087f76f6177adf44399fb6b2ed43c3b865ca8af0de4b37cfef5357b24980e11ee2cb1ed7e3541764319c70'
  end

  config.middleware.insert_before 0, 'Rack::Cors' do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :delete]
    end
  end

  S3Upload.configuration do |config|
    config.fog_params = {
        provider:              'AWS',
        aws_access_key_id:     ENV['AWS_ACCESS_KEY'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region:                ENV['AWS_REGION'] || 'us-west-2'
    }
    config.bucket  = 'curago-staging'
    config.subdir  = 'files'
  end

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address: 'email-smtp.us-west-2.amazonaws.com',
      port: 587, # Port 25 is throttled on AWS
      user_name: 'AKIAIJ767QJKJRCQ45UQ', # Your SMTP user here.
      password: 'As6Sc0bXvxuLk/ROuDdJSK/tvg+2sDcgEnDYIhgGNpdX', # Your SMTP password here.
      authentication: :login,
      enable_starttls_auto: true
  }
  ActionMailer::Base.default from: 'bdrazhzhov@weezlabs.com'
end
