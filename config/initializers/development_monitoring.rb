# frozen_string_literal: true

# Enhanced monitoring and logging for development environment
if Rails.env.development?

  # Custom logger with enhanced formatting
  class DevelopmentLogger < ActiveSupport::Logger
    def format_message(severity, timestamp, progname, msg)
      # Enhanced log format with colors and icons
      icon = case severity
             when 'DEBUG' then '🐛'
             when 'INFO' then '💡'
             when 'WARN' then '⚠️'
             when 'ERROR' then '❌'
             when 'FATAL' then '💀'
             else '📝'
             end
      
      timestamp_str = timestamp.strftime('%H:%M:%S.%3N')
      
      "#{icon} [#{timestamp_str}] #{severity.ljust(5)} -- #{progname}: #{msg}\n"
    end
  end

  # Request/Response logging
  class RequestResponseLogger
    def initialize(app)
      @app = app
    end

    def call(env)
      start_time = Time.current
      request = ActionDispatch::Request.new(env)
      
      # Log incoming request
      if ENV['LOG_REQUESTS']
        Rails.logger.info "📥 #{request.method} #{request.path} from #{request.remote_ip}"
        Rails.logger.debug "📋 Headers: #{request.headers.env.select { |k, v| k.start_with?('HTTP_') }.to_h}"
        Rails.logger.debug "📋 Params: #{request.params}" if request.params.any?
      end

      status, headers, response = @app.call(env)
      
      # Log response
      if ENV['LOG_REQUESTS']
        duration = ((Time.current - start_time) * 1000).round(2)
        status_icon = status < 300 ? '✅' : status < 400 ? '⚠️' : '❌'
        Rails.logger.info "#{status_icon} #{status} #{request.method} #{request.path} in #{duration}ms"
      end

      [status, headers, response]
    end
  end

  # SQL Query logging enhancements
  ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, unique_id, data|
    duration = ((finished - started) * 1000).round(2)
    
    if ENV['LOG_SQL']
      if duration > 100
        Rails.logger.warn "🐌 SLOW QUERY (#{duration}ms): #{data[:sql]}"
      elsif ENV['LOG_ALL_SQL']
        Rails.logger.debug "🗃️  SQL (#{duration}ms): #{data[:sql]}"
      end
    end

    # Track query statistics
    if ENV['TRACK_QUERY_STATS']
      @query_stats ||= { count: 0, total_time: 0, slow_queries: 0 }
      @query_stats[:count] += 1
      @query_stats[:total_time] += duration
      @query_stats[:slow_queries] += 1 if duration > 100
    end
  end

  # Action Controller logging
  ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, started, finished, unique_id, data|
    duration = ((finished - started) * 1000).round(2)
    
    if ENV['LOG_CONTROLLERS']
      controller = data[:controller]
      action = data[:action]
      status = data[:status]
      
      Rails.logger.info "🎮 #{controller}##{action} -> #{status} in #{duration}ms"
      
      if data[:view_runtime]
        Rails.logger.debug "🖼️  View: #{data[:view_runtime].round(2)}ms"
      end
      
      if data[:db_runtime]
        Rails.logger.debug "🗃️  DB: #{data[:db_runtime].round(2)}ms"
      end
    end
  end

  # Memory usage monitoring (conditional loading)
  if ENV['MONITOR_MEMORY']
    begin
      require 'get_process_mem'
      
      ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, started, finished, unique_id, data|
        mem = GetProcessMem.new
        Rails.logger.info "💾 Memory: #{mem.mb.round(2)}MB"
      end
    rescue LoadError
      Rails.logger.warn "get_process_mem gem not available for memory monitoring"
    end
  end

  # Custom middleware for development monitoring
  Rails.application.configure do
    unless ENV['DISABLE_REQUEST_LOGGING']
      config.middleware.use RequestResponseLogger
    end
    
    # Enhanced logger
    if ENV['ENHANCED_LOGGING']
      config.logger = DevelopmentLogger.new(Rails.root.join('log', "#{Rails.env}.log"))
    end
  end

  # Development console helpers
  Rails.application.console do
    def query_stats
      @query_stats || { count: 0, total_time: 0, slow_queries: 0 }
    end
    
    def reset_query_stats
      @query_stats = { count: 0, total_time: 0, slow_queries: 0 }
    end
    
    def log_queries(&block)
      original_log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = :debug
      result = block.call
      ActiveRecord::Base.logger.level = original_log_level
      result
    end
    
    def benchmark(label = 'Operation', &block)
      result = nil
      time = Benchmark.measure { result = block.call }
      puts "⏱️  #{label}: #{(time.real * 1000).round(2)}ms"
      result
    end
    
    puts "🔍 Development monitoring helpers loaded:"
    puts "   query_stats - Show SQL query statistics"
    puts "   reset_query_stats - Reset query counters"
    puts "   log_queries { block } - Enable SQL logging for block"
    puts "   benchmark('label') { block } - Measure execution time"
  end

  # Background job monitoring
  if defined?(Sidekiq)
    Sidekiq.configure_server do |config|
      config.logger.formatter = proc do |severity, datetime, progname, msg|
        "🔄 [#{datetime.strftime('%H:%M:%S')}] #{severity}: #{msg}\n"
      end
    end
  end

  # File change monitoring
  if ENV['LOG_FILE_CHANGES']
    Rails.application.configure do
      config.file_watcher = Class.new(ActiveSupport::EventedFileUpdateChecker) do
        def execute_if_updated
          super do
            Rails.logger.info "🔄 Files changed, reloading..."
            yield
          end
        end
      end
    end
  end

end