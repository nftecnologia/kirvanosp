# frozen_string_literal: true

# Development profiling and performance monitoring tools
if Rails.env.development?

  # Performance tracking middleware
  class PerformanceTracker
    def initialize(app)
      @app = app
      @stats = {
        requests: 0,
        total_time: 0,
        slow_requests: 0,
        errors: 0,
        memory_usage: []
      }
    end

    def call(env)
      start_time = Time.current
      start_memory = memory_usage if ENV['TRACK_MEMORY']
      
      begin
        status, headers, response = @app.call(env)
        
        # Track performance metrics
        duration = ((Time.current - start_time) * 1000).round(2)
        @stats[:requests] += 1
        @stats[:total_time] += duration
        @stats[:slow_requests] += 1 if duration > 1000
        
        if ENV['TRACK_MEMORY'] && start_memory
          end_memory = memory_usage
          memory_diff = end_memory - start_memory
          @stats[:memory_usage] << memory_diff if memory_diff > 0
        end
        
        # Log performance warnings
        if duration > 1000
          Rails.logger.warn "🐌 Slow request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']} took #{duration}ms"
        end
        
        [status, headers, response]
      rescue => e
        @stats[:errors] += 1
        Rails.logger.error "💥 Request error: #{e.class.name}: #{e.message}"
        raise
      end
    end

    def stats
      avg_time = @stats[:requests] > 0 ? (@stats[:total_time] / @stats[:requests]).round(2) : 0
      avg_memory = @stats[:memory_usage].any? ? (@stats[:memory_usage].sum / @stats[:memory_usage].size).round(2) : 0
      
      {
        total_requests: @stats[:requests],
        average_response_time: avg_time,
        slow_requests: @stats[:slow_requests],
        error_rate: @stats[:requests] > 0 ? ((@stats[:errors].to_f / @stats[:requests]) * 100).round(2) : 0,
        average_memory_usage: avg_memory
      }
    end

    private

    def memory_usage
      if defined?(GetProcessMem)
        GetProcessMem.new.mb
      else
        0
      end
    end
  end

  # Database query profiling
  class QueryProfiler
    def initialize
      @queries = []
      @duplicate_queries = Hash.new(0)
    end

    def track_query(name, started, finished, unique_id, data)
      duration = ((finished - started) * 1000).round(3)
      query_info = {
        sql: data[:sql],
        duration: duration,
        location: caller_locations(15, 5).map(&:to_s).find { |line| line.include?('/app/') }
      }
      
      @queries << query_info
      @duplicate_queries[data[:sql]] += 1
      
      # Warn about potential N+1 queries
      if @duplicate_queries[data[:sql]] > 5
        Rails.logger.warn "⚠️  Potential N+1 query detected: #{data[:sql].truncate(100)}"
      end
    end

    def report
      return if @queries.empty?
      
      total_time = @queries.sum { |q| q[:duration] }
      slow_queries = @queries.select { |q| q[:duration] > 100 }
      duplicates = @duplicate_queries.select { |_, count| count > 1 }
      
      puts "\n" + "="*80
      puts "🔍 DATABASE QUERY REPORT"
      puts "="*80
      puts "Total queries: #{@queries.size}"
      puts "Total time: #{total_time.round(2)}ms"
      puts "Slow queries (>100ms): #{slow_queries.size}"
      puts "Duplicate queries: #{duplicates.size}"
      
      if slow_queries.any?
        puts "\n📊 SLOWEST QUERIES:"
        slow_queries.sort_by { |q| -q[:duration] }.first(5).each_with_index do |query, index|
          puts "#{index + 1}. #{query[:duration]}ms: #{query[:sql].truncate(80)}"
          puts "   Location: #{query[:location]}" if query[:location]
        end
      end
      
      if duplicates.any?
        puts "\n🔄 MOST DUPLICATED QUERIES:"
        duplicates.sort_by { |_, count| -count }.first(5).each do |sql, count|
          puts "#{count}x: #{sql.truncate(80)}"
        end
      end
      
      puts "="*80 + "\n"
    end

    def reset
      @queries.clear
      @duplicate_queries.clear
    end
  end

  # Memory profiling
  if ENV['ENABLE_MEMORY_PROFILING']
    require 'memory_profiler' if defined?(MemoryProfiler)
    
    class MemoryProfilerMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        if env['HTTP_X_MEMORY_PROFILE'] == 'true' && defined?(MemoryProfiler)
          report = MemoryProfiler.report do
            @app.call(env)
          end
          
          # Save memory report
          filename = "tmp/memory_profile_#{Time.current.to_i}.txt"
          File.write(filename, report.pretty_print)
          Rails.logger.info "💾 Memory profile saved to #{filename}"
          
          [200, { 'Content-Type' => 'text/plain' }, [report.pretty_print]]
        else
          @app.call(env)
        end
      end
    end
    
    Rails.application.configure do
      config.middleware.use MemoryProfilerMiddleware
    end
  end

  # Initialize profiling tools
  performance_tracker = PerformanceTracker.new(Rails.application)
  query_profiler = QueryProfiler.new

  # Subscribe to notifications
  ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, unique_id, data|
    query_profiler.track_query(name, started, finished, unique_id, data)
  end

  # Add middleware
  Rails.application.configure do
    config.middleware.use PerformanceTracker unless ENV['DISABLE_PERFORMANCE_TRACKING']
  end

  # Console helpers for profiling
  Rails.application.console do
    def profile_memory(&block)
      if defined?(MemoryProfiler)
        report = MemoryProfiler.report(&block)
        puts report.pretty_print
        report
      else
        puts "MemoryProfiler gem not available"
        nil
      end
    end
    
    def profile_queries(&block)
      query_profiler = QueryProfiler.new
      
      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, unique_id, data|
        query_profiler.track_query(name, started, finished, unique_id, data)
      end
      
      result = block.call
      ActiveSupport::Notifications.unsubscribe(subscriber)
      query_profiler.report
      result
    end
    
    def benchmark_allocation(&block)
      if defined?(MemoryProfiler)
        report = MemoryProfiler.report(&block)
        puts "Total allocated: #{report.total_allocated} objects (#{report.total_allocated_memsize} bytes)"
        puts "Total retained: #{report.total_retained} objects (#{report.total_retained_memsize} bytes)"
        report
      else
        puts "MemoryProfiler gem not available"
        nil
      end
    end
    
    def performance_stats
      if defined?(performance_tracker)
        performance_tracker.stats
      else
        puts "Performance tracker not available"
      end
    end
    
    puts "🚀 Performance profiling helpers loaded:"
    puts "   profile_memory { block } - Profile memory usage"
    puts "   profile_queries { block } - Profile database queries"
    puts "   benchmark_allocation { block } - Benchmark memory allocation"
    puts "   performance_stats - Show performance statistics"
  end

  # Rack Mini Profiler enhancements
  if defined?(Rack::MiniProfiler)
    Rack::MiniProfiler.config.enable_advanced_debugging_tools = true
    
    # Custom timing for important operations
    class TimingHelper
      def self.time(name, &block)
        Rack::MiniProfiler.step(name, &block)
      end
    end
    
    # Make timing helper available globally
    Object.const_set('Timing', TimingHelper) unless defined?(Timing)
  end

  # Automatic performance warnings
  ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, started, finished, unique_id, data|
    duration = ((finished - started) * 1000).round(2)
    
    # Warn about slow controller actions
    if duration > 1000
      Rails.logger.warn "🐌 Slow controller action: #{data[:controller]}##{data[:action]} took #{duration}ms"
    end
    
    # Warn about excessive database time
    if data[:db_runtime] && data[:db_runtime] > 500
      Rails.logger.warn "🗃️  High database time: #{data[:db_runtime].round(2)}ms in #{data[:controller]}##{data[:action]}"
    end
    
    # Warn about excessive view rendering time
    if data[:view_runtime] && data[:view_runtime] > 500
      Rails.logger.warn "🖼️  Slow view rendering: #{data[:view_runtime].round(2)}ms in #{data[:controller]}##{data[:action]}"
    end
  end

end