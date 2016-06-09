Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes                       = false

  # Do not eager load code on boot.
  config.eager_load                          = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local         = true
  config.action_controller.perform_caching   = false

  # Don't care if the mailer can't send.
  #config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation          = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error       = :page_load


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options   = {host: 'localhost', port: 3000}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address: 'smtp.mandrillapp.com',
      port: 587, # ports 587 and 2525 are also supported with STARTTLS
      enable_starttls_auto: true, # detects and uses STARTTLS
      user_name: ENV['MANDRILL_USERNAME'],
      password: ENV['MANDRILL_PASSWORD'], # SMTP password is any valid API key
      authentication: 'login', # Mandrill supports 'plain' or 'login'
      domain: 'curagolife.com', # your domain to identify your server when connecting
  }
  ActionMailer::Base.default from: 'app@curagolife.com'

  S3Upload.configuration do |config|
    config.fog_params = {
        provider:   'Local',
        local_root: "#{Rails.root}/public",
        endpoint:   'http://localhost:3000'
    }
  end

  PubnubHelper.configuration do |config|
    config.subscribe_key = 'sub-c-b30e1dac-d56c-11e5-b684-02ee2ddab7fe'
    config.publish_key = 'pub-c-dc0c88cf-f1dd-468d-88a4-160c26eb981d'
  end

  ApiHelper.configuration do |config|
    config.aws_access_key_id = ENV['AWS_ACCESS_KEY']
    config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    config.region = ENV['AWS_REGION'] || 'us-west-2'
    config.aws_app_arn = ENV['AWS_APP_ARN']

  end

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
    #Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    #Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
  end
end
