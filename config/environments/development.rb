Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    # Use Redis cache store for better performance in development
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_URL'],
      pool: { size: 5, timeout: 5 },
      connect_timeout: 1,
      read_timeout: 1,
      write_timeout: 1,
      reconnect_attempts: 1
    }
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{1.hour.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end
  config.public_file_server.enabled = true

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE', 'local').to_sym

  config.active_job.queue_adapter = :sidekiq

  Rails.application.routes.default_url_options = { host: ENV['FRONTEND_URL'] }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # Disable for better performance in development
  config.assets.debug = false
  config.assets.compile = true
  config.assets.digest = false

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Disable host check during development
  config.hosts = nil
  
  # GitHub Codespaces configuration
  if ENV['CODESPACES']
    # Allow web console access from any IP
    config.web_console.allowed_ips = %w(0.0.0.0/0 ::/0)
    # Allow CSRF from codespace URLs
    config.force_ssl = false
    config.action_controller.forgery_protection_origin_check = false
  end

  # customize using the environment variables
  config.log_level = ENV.fetch('LOG_LEVEL', 'debug').to_sym

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  config.logger = ActiveSupport::Logger.new(Rails.root.join('log', "#{Rails.env}.log"), 1, ENV.fetch('LOG_SIZE', '1024').to_i.megabytes)

  # Bullet configuration to fix the N+1 queries
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
  end

  # Performance optimizations for development
  # Reduce timeout for faster failure detection
  config.force_ssl = false
  
  # Configure timeout for development (faster detection of hanging requests)
  if defined?(Rack::Timeout)
    # Add request timeout middleware
    config.middleware.insert_before ActionDispatch::ShowExceptions, Rack::Timeout::Middleware
    Rack::Timeout.timeout = 30  # 30 seconds timeout instead of default 15
    Rack::Timeout.wait_timeout = 5   # 5 seconds wait timeout
  end
end
