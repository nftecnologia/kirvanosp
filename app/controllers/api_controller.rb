class ApiController < ApplicationController
  skip_before_action :set_current_user, only: [:index, :health]

  def index
    render json: { version: Kirvano.config[:version],
                   timestamp: Time.now.utc.to_fs(:db),
                   queue_services: redis_status,
                   data_services: postgres_status }
  end

  def health
    health_data = comprehensive_health_check
    
    # Return 503 if any critical service is failing
    status_code = health_data[:status] == 'healthy' ? 200 : 503
    
    render json: health_data, status: status_code
  end

  private

  def comprehensive_health_check
    start_time = Time.current
    
    checks = {
      database: check_database,
      redis: check_redis,
      sidekiq: check_sidekiq,
      storage: check_storage,
      memory: check_memory,
      application: check_application_health
    }
    
    # Determine overall status
    overall_status = checks.values.all? { |check| check[:status] == 'ok' } ? 'healthy' : 'unhealthy'
    
    {
      status: overall_status,
      timestamp: start_time.utc.to_fs(:db),
      response_time: ((Time.current - start_time) * 1000).round(2),
      version: Kirvano.config[:version],
      environment: Rails.env,
      checks: checks
    }
  end

  def check_database
    start_time = Time.current
    
    begin
      # Test basic connection
      ActiveRecord::Base.connection.execute('SELECT 1')
      
      # Test query performance
      query_time = Time.current
      account_count = Account.count
      conversation_count = Conversation.count
      query_duration = ((Time.current - query_time) * 1000).round(2)
      
      {
        status: 'ok',
        response_time: ((Time.current - start_time) * 1000).round(2),
        details: {
          accounts: account_count,
          conversations: conversation_count,
          query_time: query_duration
        }
      }
    rescue => e
      {
        status: 'error',
        response_time: ((Time.current - start_time) * 1000).round(2),
        error: e.message
      }
    end
  end

  def check_redis
    start_time = Time.current
    
    begin
      redis = Redis.new(Redis::Config.app)
      redis.ping
      
      # Test Redis functionality
      test_key = "health_check_#{SecureRandom.hex(8)}"
      redis.set(test_key, 'test', ex: 10)
      redis.get(test_key)
      redis.del(test_key)
      
      {
        status: 'ok',
        response_time: ((Time.current - start_time) * 1000).round(2),
        details: {
          connected: true,
          memory_usage: redis.info('memory')['used_memory_human']
        }
      }
    rescue => e
      {
        status: 'error',
        response_time: ((Time.current - start_time) * 1000).round(2),
        error: e.message
      }
    end
  end

  def check_sidekiq
    start_time = Time.current
    
    begin
      require 'sidekiq/api'
      
      stats = Sidekiq::Stats.new
      processes = Sidekiq::ProcessSet.new.size
      
      # Check for excessive queue buildup
      high_queue_threshold = 1000
      queues_status = stats.queues.any? { |_, size| size > high_queue_threshold } ? 'warning' : 'ok'
      
      {
        status: processes > 0 ? queues_status : 'error',
        response_time: ((Time.current - start_time) * 1000).round(2),
        details: {
          processes: processes,
          enqueued: stats.enqueued,
          processed: stats.processed,
          failed: stats.failed,
          retry_count: stats.retry_size,
          queues: stats.queues
        }
      }
    rescue => e
      {
        status: 'error',
        response_time: ((Time.current - start_time) * 1000).round(2),
        error: e.message
      }
    end
  end

  def check_storage
    start_time = Time.current
    
    begin
      # Test Active Storage functionality
      blob_count = ActiveStorage::Blob.count
      
      {
        status: 'ok',
        response_time: ((Time.current - start_time) * 1000).round(2),
        details: {
          service: Rails.application.config.active_storage.service,
          blobs: blob_count
        }
      }
    rescue => e
      {
        status: 'error',
        response_time: ((Time.current - start_time) * 1000).round(2),
        error: e.message
      }
    end
  end

  def check_memory
    start_time = Time.current
    
    begin
      # Get basic memory info (works on most Unix systems)
      memory_info = if File.exist?('/proc/meminfo')
        File.read('/proc/meminfo').lines.each_with_object({}) do |line, hash|
          key, value = line.split(':')
          hash[key.strip] = value.strip if value
        end
      else
        { 'MemTotal' => 'Unknown', 'MemAvailable' => 'Unknown' }
      end
      
      {
        status: 'ok',
        response_time: ((Time.current - start_time) * 1000).round(2),
        details: {
          total: memory_info['MemTotal'],
          available: memory_info['MemAvailable'],
          ruby_memory: "#{(GC.stat[:heap_allocated_pages] * GC::INTERNAL_CONSTANTS[:HEAP_PAGE_SIZE] / 1024 / 1024).round(2)} MB"
        }
      }
    rescue => e
      {
        status: 'warning',
        response_time: ((Time.current - start_time) * 1000).round(2),
        error: e.message
      }
    end
  end

  def check_application_health
    start_time = Time.current
    
    begin
      # Test core application functionality
      recent_articles = Article.where('created_at > ?', 24.hours.ago).count
      recent_conversations = Conversation.where('created_at > ?', 24.hours.ago).count
      active_users = User.joins(:account_users).where('account_users.active_at > ?', 1.hour.ago).count
      
      {
        status: 'ok',
        response_time: ((Time.current - start_time) * 1000).round(2),
        details: {
          articles_24h: recent_articles,
          conversations_24h: recent_conversations,
          active_users_1h: active_users,
          uptime: Time.current - Rails.application.initialized_at
        }
      }
    rescue => e
      {
        status: 'warning',
        response_time: ((Time.current - start_time) * 1000).round(2),
        error: e.message
      }
    end
  end

  def redis_status
    r = Redis.new(Redis::Config.app)
    return 'ok' if r.ping
  rescue Redis::CannotConnectError
    'failing'
  end

  def postgres_status
    ActiveRecord::Base.connection.active? ? 'ok' : 'failing'
  rescue ActiveRecord::ConnectionNotEstablished
    'failing'
  end
end
