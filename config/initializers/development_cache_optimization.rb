# Development Cache Optimization Configuration
# This file configures caching optimizations specifically for local development
# to maximize performance and developer productivity

if Rails.env.development?
  Rails.application.configure do
    # Enhanced local caching configuration
    config.cache_store = :redis_cache_store, {
      url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
      pool: {
        size: 10,           # Increased pool size for better concurrency
        timeout: 2,         # Faster timeout for development
      },
      connect_timeout: 0.5, # Very fast connection timeout
      read_timeout: 1,      # Quick read operations
      write_timeout: 1,     # Quick write operations
      reconnect_attempts: 2,
      
      # Development-specific cache options
      expires_in: 1.hour,   # Shorter expiration for development
      namespace: "kirvano_dev_#{Rails.env}",
      compress: false,      # Disable compression for speed in dev
      
      # Error handling - don't fail hard in development
      error_handler: ->(method:, returning:, exception:) {
        Rails.logger.warn "Cache error in development: #{exception.class} - #{exception.message}"
        Rails.logger.warn "Falling back to in-memory cache"
        nil
      }
    }
    
    # Enable query caching for better database performance
    config.active_record.cache_versioning = true
    config.active_record.collection_cache_versioning = true
    
    # Fragment caching optimizations
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = false # Reduce log noise
    
    # View caching for development
    config.action_view.cache_template_loading = true
    
    # Asset caching configuration
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=3600', # 1 hour for development assets
      'Vary' => 'Accept-Encoding'
    }
  end
  
  # Configure ActionCable for better performance
  ActionCable.server.config.cable = {
    adapter: 'redis',
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/2'),
    channel_prefix: "kirvano_dev_#{Rails.env}",
    
    # Development-specific ActionCable optimizations
    pool: 5,
    timeout: 1,
    reconnect_attempts: 3
  }
  
  # HTTP caching middleware for API responses
  Rails.application.config.middleware.use Rack::ConditionalGet
  Rails.application.config.middleware.use Rack::ETag
  
  # Development-specific cache warming
  Rails.application.config.after_initialize do
    # Warm up commonly used caches in development
    if defined?(Rails::Server)
      Thread.new do
        begin
          # Pre-warm translation cache
          I18n.backend.send(:init_translations) if I18n.backend.respond_to?(:init_translations, true)
          
          # Pre-warm asset path cache
          Rails.application.assets&.cached if Rails.application.assets
          
          Rails.logger.info "Development cache warming completed"
        rescue => e
          Rails.logger.warn "Cache warming failed: #{e.message}"
        end
      end
    end
  end
end