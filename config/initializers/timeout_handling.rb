# Timeout Handling for Development Performance
# Gracefully handle timeouts and provide user-friendly error messages

if Rails.env.development? && defined?(Rack::Timeout)
  # Timeout middleware is configured in development.rb to avoid duplicates

  # Custom error handling for timeouts
  Rails.application.config.exceptions_app = proc do |env|
    exception = env['action_dispatch.exception']
    
    if defined?(Rack::Timeout::RequestTimeoutException) && exception.is_a?(Rack::Timeout::RequestTimeoutException)
      # Handle request timeouts gracefully
      [408, 
       { 'Content-Type' => 'application/json' }, 
       [{ 
         error: 'Request timed out', 
         message: 'The request took too long to process. This might be due to slow external services.',
         suggestion: 'Try switching to local services with: bin/switch-to-local'
       }.to_json]]
    else
      # Let Rails handle other exceptions normally
      ActionDispatch::PublicExceptions.new(Rails.public_path).call(env)
    end
  end

  # Log slow queries with suggestions
  ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
    duration = finish - start
    if duration > 1.0 # Log queries slower than 1 second
      Rails.logger.warn "Slow Query (#{duration.round(2)}s): #{payload[:sql]}"
      if payload[:sql].include?('SELECT')
        Rails.logger.warn "💡 Consider adding database indexes or switching to local database"
      end
    end
  end
end