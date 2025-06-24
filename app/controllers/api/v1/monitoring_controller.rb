class Api::V1::MonitoringController < Api::V1::BaseController
  before_action :check_authorization
  
  def metrics
    render json: {
      performance: performance_metrics,
      business: business_metrics,
      infrastructure: infrastructure_metrics,
      security: security_metrics
    }
  end

  def alerts
    render json: {
      active_alerts: active_alerts,
      recent_incidents: recent_incidents,
      system_warnings: system_warnings
    }
  end

  def database_performance
    render json: {
      comprehensive: Monitoring::DatabasePerformanceService.comprehensive_database_metrics,
      query_analysis: Monitoring::DatabasePerformanceService.query_analysis,
      legacy_metrics: {
        query_performance: database_query_metrics,
        connection_pool: connection_pool_metrics,
        slow_queries: slow_queries_analysis
      }
    }
  end

  def article_metrics
    render json: {
      health: Monitoring::ArticleMetricsService.article_health_metrics,
      performance: Monitoring::ArticleMetricsService.article_performance_metrics
    }
  end

  def sidekiq_metrics
    render json: {
      comprehensive: Monitoring::SidekiqMonitoringService.comprehensive_metrics,
      health: Monitoring::SidekiqMonitoringService.queue_health_status,
      performance: Monitoring::SidekiqMonitoringService.performance_analysis
    }
  end

  def uptime_status
    render json: {
      external_services: Monitoring::UptimeMonitoringService.external_service_checks,
      uptime_metrics: Monitoring::UptimeMonitoringService.uptime_metrics,
      dependencies: Monitoring::UptimeMonitoringService.service_dependencies
    }
  end

  private

  def check_authorization
    return render json: { error: 'Unauthorized' }, status: 401 unless current_user&.administrator?
  end

  def performance_metrics
    {
      response_times: {
        avg_response_time: calculate_avg_response_time,
        p95_response_time: calculate_p95_response_time,
        requests_per_minute: calculate_requests_per_minute
      },
      memory_usage: {
        heap_size: GC.stat[:heap_allocated_pages] * GC::INTERNAL_CONSTANTS[:HEAP_PAGE_SIZE],
        heap_pages: GC.stat[:heap_allocated_pages],
        gc_count: GC.stat[:count]
      },
      cache_performance: {
        hit_rate: calculate_cache_hit_rate,
        miss_rate: calculate_cache_miss_rate
      }
    }
  end

  def business_metrics
    {
      articles: {
        total: Article.count,
        published: Article.where(status: 'published').count,
        today: Article.where('created_at > ?', 1.day.ago).count,
        this_week: Article.where('created_at > ?', 1.week.ago).count
      },
      conversations: {
        total: Conversation.count,
        active: Conversation.where(status: 'open').count,
        resolved_today: Conversation.where(status: 'resolved', updated_at: 1.day.ago..Time.current).count,
        avg_resolution_time: calculate_avg_resolution_time
      },
      users: {
        total: User.count,
        active_today: User.joins(:account_users).where('account_users.active_at > ?', 1.day.ago).distinct.count,
        active_this_week: User.joins(:account_users).where('account_users.active_at > ?', 1.week.ago).distinct.count
      },
      accounts: {
        total: Account.count,
        active: Account.where(status: 'active').count,
        premium: Account.joins(:account_users).where('feature_flags > 0').distinct.count
      }
    }
  end

  def infrastructure_metrics
    {
      database: {
        connection_count: ActiveRecord::Base.connection_pool.stat[:size],
        available_connections: ActiveRecord::Base.connection_pool.stat[:available],
        query_cache_hit_rate: calculate_db_cache_hit_rate
      },
      redis: {
        memory_usage: redis_memory_usage,
        connected_clients: redis_connected_clients,
        commands_per_second: redis_commands_per_second
      },
      sidekiq: {
        processed: Sidekiq::Stats.new.processed,
        failed: Sidekiq::Stats.new.failed,
        enqueued: Sidekiq::Stats.new.enqueued,
        retry_size: Sidekiq::Stats.new.retry_size,
        dead_size: Sidekiq::Stats.new.dead_size,
        processes_count: Sidekiq::ProcessSet.new.size,
        busy_workers: Sidekiq::Workers.new.size
      }
    }
  end

  def security_metrics
    {
      failed_logins: {
        last_hour: failed_logins_count(1.hour.ago),
        last_24h: failed_logins_count(1.day.ago),
        unique_ips: failed_logins_unique_ips(1.day.ago)
      },
      api_security: {
        blocked_requests: blocked_requests_count,
        rate_limited_requests: rate_limited_requests_count
      }
    }
  end

  def active_alerts
    alerts = []
    
    # Database connection alerts
    if ActiveRecord::Base.connection_pool.stat[:available] < 2
      alerts << {
        type: 'critical',
        service: 'database',
        message: 'Low database connection pool availability',
        value: ActiveRecord::Base.connection_pool.stat[:available],
        threshold: 2
      }
    end

    # Redis memory alerts
    redis_memory = redis_memory_usage_bytes
    if redis_memory > 500_000_000 # 500MB
      alerts << {
        type: 'warning',
        service: 'redis',
        message: 'High Redis memory usage',
        value: redis_memory,
        threshold: 500_000_000
      }
    end

    # Sidekiq queue alerts
    total_enqueued = Sidekiq::Stats.new.enqueued
    if total_enqueued > 1000
      alerts << {
        type: 'warning',
        service: 'sidekiq',
        message: 'High job queue backlog',
        value: total_enqueued,
        threshold: 1000
      }
    end

    # Failed jobs alerts
    failed_count = Sidekiq::Stats.new.failed
    if failed_count > 100
      alerts << {
        type: 'critical',
        service: 'sidekiq',
        message: 'High number of failed jobs',
        value: failed_count,
        threshold: 100
      }
    end

    alerts
  end

  def recent_incidents
    # This would typically connect to your incident management system
    # For now, we'll check for recent error spikes
    incidents = []
    
    # Check for recent Sidekiq failures
    if Sidekiq::Stats.new.failed > 50
      incidents << {
        timestamp: Time.current,
        type: 'job_failures',
        description: 'Increased job failure rate detected',
        status: 'investigating'
      }
    end

    incidents
  end

  def system_warnings
    warnings = []
    
    # Check for old articles without updates
    stale_articles = Article.where('updated_at < ?', 30.days.ago).count
    if stale_articles > 100
      warnings << {
        type: 'content_freshness',
        message: "#{stale_articles} articles haven't been updated in 30+ days"
      }
    end

    # Check for inactive users
    inactive_users = User.where('last_sign_in_at < ?', 30.days.ago).count
    if inactive_users > current_account.users.count * 0.3
      warnings << {
        type: 'user_engagement',
        message: "#{inactive_users} users haven't logged in recently"
      }
    end

    warnings
  end

  def database_query_metrics
    # This would typically use query monitoring tools like pg_stat_statements
    {
      total_queries: database_total_queries,
      avg_query_time: database_avg_query_time,
      slow_query_count: database_slow_query_count
    }
  end

  def connection_pool_metrics
    pool = ActiveRecord::Base.connection_pool
    {
      size: pool.stat[:size],
      checked_out: pool.stat[:checked_out],
      checked_in: pool.stat[:checked_in],
      available: pool.stat[:available]
    }
  end

  def slow_queries_analysis
    # This would typically analyze slow query logs
    # For now, return placeholder data
    {
      count: 5,
      avg_time: 1200, # milliseconds
      queries: [
        {
          query: "SELECT COUNT(*) FROM conversations WHERE...",
          duration: 1500,
          frequency: 23
        }
      ]
    }
  end

  # Helper methods for metric calculations
  def calculate_avg_response_time
    # This would typically use Rails request metrics or APM data
    rand(100..500) # Placeholder
  end

  def calculate_p95_response_time
    # This would typically use Rails request metrics or APM data
    rand(200..800) # Placeholder
  end

  def calculate_requests_per_minute
    # This would typically use Rails request metrics or APM data
    rand(50..200) # Placeholder
  end

  def calculate_cache_hit_rate
    # This would typically use Rails cache metrics
    rand(0.8..0.95) # Placeholder
  end

  def calculate_cache_miss_rate
    1 - calculate_cache_hit_rate
  end

  def calculate_avg_resolution_time
    resolved_conversations = Conversation.where(status: 'resolved')
                                        .where('updated_at > ?', 1.week.ago)
    
    return 0 if resolved_conversations.empty?
    
    total_time = resolved_conversations.sum do |conv|
      (conv.updated_at - conv.created_at).to_i
    end
    
    (total_time / resolved_conversations.count / 3600.0).round(2) # hours
  end

  def calculate_db_cache_hit_rate
    # This would use pg_stat_database or similar
    rand(0.9..0.99) # Placeholder
  end

  def redis_memory_usage
    begin
      redis = Redis.new(Redis::Config.app)
      redis.info('memory')['used_memory_human']
    rescue
      'Unknown'
    end
  end

  def redis_memory_usage_bytes
    begin
      redis = Redis.new(Redis::Config.app)
      redis.info('memory')['used_memory'].to_i
    rescue
      0
    end
  end

  def redis_connected_clients
    begin
      redis = Redis.new(Redis::Config.app)
      redis.info('clients')['connected_clients']
    rescue
      0
    end
  end

  def redis_commands_per_second
    begin
      redis = Redis.new(Redis::Config.app)
      redis.info('stats')['instantaneous_ops_per_sec']
    rescue
      0
    end
  end

  def failed_logins_count(since)
    # This would typically query your authentication logs
    # For now, return placeholder data
    rand(0..10)
  end

  def failed_logins_unique_ips(since)
    # This would typically query your authentication logs
    # For now, return placeholder data
    rand(0..5)
  end

  def blocked_requests_count
    # This would typically query Rack::Attack or similar
    rand(0..50)
  end

  def rate_limited_requests_count
    # This would typically query Rack::Attack or similar
    rand(0..20)
  end

  def database_total_queries
    # This would use pg_stat_database
    rand(1000..5000)
  end

  def database_avg_query_time
    # This would use pg_stat_statements
    rand(10..100) # milliseconds
  end

  def database_slow_query_count
    # This would use pg_stat_statements
    rand(0..10)
  end
end