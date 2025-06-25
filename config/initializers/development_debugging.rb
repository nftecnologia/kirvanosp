# frozen_string_literal: true

# Development debugging and profiling tools configuration
if Rails.env.development?
  
  # Rack Mini Profiler enhancements
  if defined?(Rack::MiniProfiler)
    # Skip profiling for certain paths
    Rack::MiniProfiler.config.skip_paths = [
      '/assets/',
      '/packs/',
      '/vite/',
      '/favicon.ico'
    ]
    
    # Configure authorization for profiler
    Rack::MiniProfiler.config.authorization_mode = :allow_all
    
    # Storage adapter for profiler data
    Rack::MiniProfiler.config.storage_options = {
      path: Rails.root.join('tmp', 'miniprofiler')
    }
    
    # Enable memory profiling
    Rack::MiniProfiler.config.enable_advanced_debugging_tools = true
    
    # Position profiler results
    Rack::MiniProfiler.config.position = 'top-left'
  end

  # Enhanced logging for development
  Rails.application.configure do
    # Colorized logs
    config.colorize_logging = true
    
    # Log level based on environment variable
    config.log_level = ENV.fetch('LOG_LEVEL', 'debug').to_sym
    
    # Tagged logging for better debugging
    config.log_tags = [
      :request_id,
      -> { "PID-#{Process.pid}" },
      -> { Time.current.strftime('%H:%M:%S') }
    ]
  end

  # Development console enhancements
  Rails.application.console do
    # Load useful development methods
    def reload!
      puts "Reloading Rails application..."
      Rails.application.reloader.reload!
      puts "Reloaded!"
    end
    
    def show_routes(controller = nil)
      if controller
        Rails.application.routes.routes.select { |r| r.defaults[:controller] == controller.to_s }
      else
        Rails.application.routes.routes
      end.map { |r| "#{r.verb.ljust(7)} #{r.path.spec}" }
    end
    
    def show_models
      Rails.application.eager_load!
      ApplicationRecord.descendants.map(&:name).sort
    end
    
    def last_queries(limit = 10)
      ActiveRecord::Base.connection.instance_variable_get(:@query_cache)&.last(limit) || []
    end
    
    puts "🚀 Kirvano Development Console Ready!"
    puts "Available helpers: reload!, show_routes, show_models, last_queries"
  end

  # Memory profiling configuration
  if ENV['MEMORY_PROFILER'] && defined?(MemoryProfiler)
    # Allow memory profiling with ?pp=profile-memory
    Rack::MiniProfiler.config.enable_advanced_debugging_tools = true
  end

  # SQL query analysis
  if ENV['QUERY_ANALYSIS']
    ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, unique_id, data|
      duration = ((finished - started) * 1000).round(2)
      if duration > 100 # Log slow queries (>100ms)
        Rails.logger.warn "🐌 SLOW QUERY (#{duration}ms): #{data[:sql]}"
      end
    end
  end

  # Hot reloading enhancements
  if ENV['ENHANCED_RELOADING']
    # Listen for file changes more efficiently
    Rails.application.configure do
      config.file_watcher = ActiveSupport::EventedFileUpdateChecker
      config.reload_classes_only_on_change = true
    end
  end

end