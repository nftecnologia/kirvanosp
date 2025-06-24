if ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.enabled_environments = %w[staging production]
    config.environment = Rails.env
    config.release = ENV['RAILWAY_GIT_COMMIT_SHA'] || ENV['GIT_SHA'] || 'unknown'

    # Performance monitoring
    config.traces_sample_rate = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', '0.1').to_f
    config.profiles_sample_rate = ENV.fetch('SENTRY_PROFILES_SAMPLE_RATE', '0.1').to_f

    # Error filtering and configuration
    config.excluded_exceptions += [
      'Rack::Timeout::RequestTimeoutException',
      'ActionController::RoutingError',
      'ActionController::InvalidAuthenticityToken',
      'ActionDispatch::Http::MimeNegotiation::InvalidType'
    ]

    # Sensitive data configuration
    config.send_default_pii = true unless ENV['DISABLE_SENTRY_PII']
    
    # Custom tags for better error categorization
    config.tags = {
      component: 'kirvano',
      version: Kirvano.config[:version],
      deployment: ENV['RAILWAY_ENVIRONMENT'] || Rails.env
    }

    # Set user context
    config.before_send = lambda do |event, hint|
      if defined?(Current) && Current.user
        event.user = {
          id: Current.user.id,
          email: Current.user.email,
          account_id: Current.account&.id
        }
      end
      event
    end

    # Custom breadcrumbs for better debugging
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Configure sampling for better performance
    config.sample_rate = ENV.fetch('SENTRY_SAMPLE_RATE', '1.0').to_f

    # Set custom fingerprinting for better error grouping
    config.before_send = lambda do |event, hint|
      # Group Redis connection errors
      if event.exception && event.exception.values.any? { |ex| ex.type == 'Redis::CannotConnectError' }
        event.fingerprint = ['redis-connection-error']
      end

      # Group database connection errors
      if event.exception && event.exception.values.any? { |ex| ex.type == 'ActiveRecord::ConnectionNotEstablished' }
        event.fingerprint = ['database-connection-error']
      end

      event
    end

    # Set context for better debugging
    config.before_send_transaction = lambda do |transaction, hint|
      transaction.set_tag('feature', 'monitoring') if transaction.name.include?('monitoring')
      transaction
    end
  end

  # Configure Sentry with Rails
  Rails.application.config.middleware.insert_before(
    Rack::Sendfile,
    Sentry::Rails::CaptureExceptions
  )
end
