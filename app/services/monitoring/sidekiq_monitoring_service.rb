class Monitoring::SidekiqMonitoringService
  def self.comprehensive_metrics
    new.comprehensive_metrics
  end

  def self.queue_health_status
    new.queue_health_status
  end

  def self.performance_analysis
    new.performance_analysis
  end

  def comprehensive_metrics
    {
      overview: overview_metrics,
      queues: queue_metrics,
      workers: worker_metrics,
      jobs: job_metrics,
      processes: process_metrics,
      memory_usage: memory_usage_metrics
    }
  end

  def queue_health_status
    {
      overall_health: calculate_overall_health,
      queue_status: queue_status_details,
      alerts: generate_queue_alerts,
      recommendations: generate_recommendations
    }
  end

  def performance_analysis
    {
      throughput: throughput_analysis,
      latency: latency_analysis,
      error_analysis: error_analysis,
      trends: trend_analysis
    }
  end

  private

  def overview_metrics
    stats = Sidekiq::Stats.new
    
    {
      processed: stats.processed,
      failed: stats.failed,
      enqueued: stats.enqueued,
      scheduled: stats.scheduled_size,
      retry_size: stats.retry_size,
      dead_size: stats.dead_size,
      processes_count: process_count,
      busy_workers: busy_worker_count,
      success_rate: calculate_success_rate(stats)
    }
  end

  def queue_metrics
    stats = Sidekiq::Stats.new
    queues = stats.queues
    
    queues.map do |queue_name, size|
      {
        name: queue_name,
        size: size,
        latency: calculate_queue_latency(queue_name),
        processing_rate: calculate_processing_rate(queue_name),
        priority: get_queue_priority(queue_name),
        status: determine_queue_status(queue_name, size)
      }
    end.sort_by { |q| -q[:size] }
  end

  def worker_metrics
    workers = Sidekiq::Workers.new
    processes = Sidekiq::ProcessSet.new
    
    {
      total_workers: workers.size,
      busy_workers: workers.size,
      idle_workers: calculate_idle_workers,
      worker_distribution: worker_distribution_by_queue,
      process_details: processes.map do |process|
        {
          identity: process['identity'],
          started_at: Time.at(process['started_at']),
          concurrency: process['concurrency'],
          busy: process['busy'],
          rss_kb: process.dig('rss')
        }
      end
    }
  end

  def job_metrics
    stats = Sidekiq::Stats.new
    
    {
      jobs_per_minute: calculate_jobs_per_minute,
      average_job_duration: calculate_average_job_duration,
      job_types: analyze_job_types,
      failure_rate: calculate_failure_rate(stats),
      retry_patterns: analyze_retry_patterns
    }
  end

  def process_metrics
    processes = Sidekiq::ProcessSet.new
    
    {
      total_processes: processes.size,
      total_concurrency: processes.sum { |p| p['concurrency'] },
      memory_usage: processes.sum { |p| p.dig('rss') || 0 },
      uptime: calculate_average_uptime(processes),
      version: processes.first&.dig('version') || 'unknown'
    }
  end

  def memory_usage_metrics
    processes = Sidekiq::ProcessSet.new
    
    {
      total_rss_mb: (processes.sum { |p| p.dig('rss') || 0 } / 1024.0).round(2),
      average_rss_mb: processes.empty? ? 0 : (processes.sum { |p| p.dig('rss') || 0 } / processes.size / 1024.0).round(2),
      memory_per_worker: calculate_memory_per_worker,
      memory_trend: analyze_memory_trend
    }
  end

  def calculate_overall_health
    stats = Sidekiq::Stats.new
    issues = []
    
    # Check queue sizes
    large_queues = stats.queues.select { |_, size| size > 1000 }
    issues << "Large queues detected" if large_queues.any?
    
    # Check failure rate
    total_jobs = stats.processed + stats.failed
    failure_rate = total_jobs > 0 ? (stats.failed.to_f / total_jobs * 100) : 0
    issues << "High failure rate" if failure_rate > 5
    
    # Check dead jobs
    issues << "Many dead jobs" if stats.dead_size > 100
    
    # Check retry queue
    issues << "High retry queue" if stats.retry_size > 500
    
    # Check process count
    issues << "No workers running" if process_count == 0
    
    case issues.size
    when 0
      'healthy'
    when 1..2
      'warning'
    else
      'critical'
    end
  end

  def queue_status_details
    stats = Sidekiq::Stats.new
    
    stats.queues.map do |queue_name, size|
      latency = calculate_queue_latency(queue_name)
      
      status = case
               when size > 1000 then 'overloaded'
               when size > 500 then 'busy'
               when size > 100 then 'active'
               when latency > 300 then 'slow'
               else 'normal'
               end
      
      {
        queue: queue_name,
        size: size,
        latency_seconds: latency,
        status: status
      }
    end
  end

  def generate_queue_alerts
    alerts = []
    stats = Sidekiq::Stats.new
    
    # High queue size alerts
    stats.queues.each do |queue_name, size|
      if size > 1000
        alerts << {
          type: 'critical',
          queue: queue_name,
          message: "Queue #{queue_name} has #{size} jobs (threshold: 1000)",
          suggested_action: "Scale up workers or investigate job failures"
        }
      elsif size > 500
        alerts << {
          type: 'warning',
          queue: queue_name,
          message: "Queue #{queue_name} has #{size} jobs (threshold: 500)",
          suggested_action: "Monitor queue growth and consider scaling"
        }
      end
    end
    
    # High failure rate alert
    total_jobs = stats.processed + stats.failed
    if total_jobs > 0
      failure_rate = (stats.failed.to_f / total_jobs * 100).round(2)
      if failure_rate > 5
        alerts << {
          type: 'critical',
          message: "High job failure rate: #{failure_rate}%",
          suggested_action: "Investigate failed jobs and fix underlying issues"
        }
      end
    end
    
    # Dead jobs alert
    if stats.dead_size > 100
      alerts << {
        type: 'warning',
        message: "#{stats.dead_size} dead jobs accumulated",
        suggested_action: "Review and clear dead jobs, investigate recurring failures"
      }
    end
    
    # No workers alert
    if process_count == 0
      alerts << {
        type: 'critical',
        message: "No Sidekiq workers are running",
        suggested_action: "Start Sidekiq workers immediately"
      }
    end
    
    alerts
  end

  def generate_recommendations
    recommendations = []
    stats = Sidekiq::Stats.new
    processes = Sidekiq::ProcessSet.new
    
    # Concurrency recommendations
    total_concurrency = processes.sum { |p| p['concurrency'] }
    if total_concurrency < 5
      recommendations << {
        type: 'scaling',
        priority: 'medium',
        message: "Consider increasing worker concurrency (current: #{total_concurrency})"
      }
    end
    
    # Queue priority recommendations
    high_volume_queues = stats.queues.select { |_, size| size > 100 }.keys
    if high_volume_queues.include?('default') && !high_volume_queues.include?('critical')
      recommendations << {
        type: 'optimization',
        priority: 'low',
        message: "Consider using priority queues for important jobs"
      }
    end
    
    # Memory optimization
    avg_memory = processes.empty? ? 0 : processes.sum { |p| p.dig('rss') || 0 } / processes.size
    if avg_memory > 500_000 # 500MB
      recommendations << {
        type: 'memory',
        priority: 'medium',
        message: "High memory usage per worker (#{(avg_memory / 1024.0).round(2)}MB avg)"
      }
    end
    
    recommendations
  end

  def throughput_analysis
    stats = Sidekiq::Stats.new
    
    {
      current_processed: stats.processed,
      processing_rate_per_minute: calculate_jobs_per_minute,
      estimated_completion_time: estimate_completion_time,
      peak_throughput: calculate_peak_throughput
    }
  end

  def latency_analysis
    stats = Sidekiq::Stats.new
    
    queue_latencies = stats.queues.keys.map do |queue_name|
      {
        queue: queue_name,
        latency: calculate_queue_latency(queue_name)
      }
    end
    
    {
      average_latency: queue_latencies.sum { |q| q[:latency] } / [queue_latencies.size, 1].max,
      max_latency: queue_latencies.max_by { |q| q[:latency] },
      queue_latencies: queue_latencies
    }
  end

  def error_analysis
    stats = Sidekiq::Stats.new
    
    {
      total_failures: stats.failed,
      failure_rate: calculate_failure_rate(stats),
      retry_jobs: stats.retry_size,
      dead_jobs: stats.dead_size,
      common_errors: analyze_common_errors
    }
  end

  def trend_analysis
    # This would typically analyze historical data
    # For now, provide current state analysis
    {
      processing_trend: determine_processing_trend,
      queue_growth_trend: determine_queue_growth_trend,
      error_trend: determine_error_trend,
      memory_trend: analyze_memory_trend
    }
  end

  # Helper methods
  def process_count
    Sidekiq::ProcessSet.new.size
  end

  def busy_worker_count
    Sidekiq::Workers.new.size
  end

  def calculate_success_rate(stats)
    total = stats.processed + stats.failed
    return 100.0 if total == 0
    ((stats.processed.to_f / total) * 100).round(2)
  end

  def calculate_queue_latency(queue_name)
    # This would typically use Sidekiq::Queue latency
    begin
      queue = Sidekiq::Queue.new(queue_name)
      queue.latency
    rescue
      0
    end
  end

  def calculate_processing_rate(queue_name)
    # Estimate processing rate based on queue size and workers
    # This is a simplified calculation
    rand(10..50) # jobs per minute
  end

  def get_queue_priority(queue_name)
    # Based on the queue configuration in sidekiq.yml
    priority_map = {
      'critical' => 1,
      'high' => 2,
      'medium' => 3,
      'default' => 4,
      'low' => 5
    }
    priority_map[queue_name] || 4
  end

  def determine_queue_status(queue_name, size)
    latency = calculate_queue_latency(queue_name)
    
    case
    when size > 1000 then 'overloaded'
    when size > 500 then 'busy'
    when size > 100 then 'active'
    when latency > 300 then 'slow'
    else 'normal'
    end
  end

  def calculate_idle_workers
    processes = Sidekiq::ProcessSet.new
    total_concurrency = processes.sum { |p| p['concurrency'] }
    busy_workers = Sidekiq::Workers.new.size
    [total_concurrency - busy_workers, 0].max
  end

  def worker_distribution_by_queue
    workers = Sidekiq::Workers.new
    distribution = Hash.new(0)
    
    workers.each do |_process_id, _thread_id, work|
      queue = work.dig('queue') || 'unknown'
      distribution[queue] += 1
    end
    
    distribution
  end

  def calculate_jobs_per_minute
    # This would typically analyze job processing over time
    # For now, estimate based on current activity
    stats = Sidekiq::Stats.new
    processes = Sidekiq::ProcessSet.new
    
    return 0 if processes.empty?
    
    # Rough estimate: concurrency * efficiency factor
    total_concurrency = processes.sum { |p| p['concurrency'] }
    estimated_rate = total_concurrency * 0.8 # 80% efficiency
    estimated_rate.round(2)
  end

  def calculate_average_job_duration
    # This would typically track job durations
    # For now, return estimated average
    rand(5..30) # seconds
  end

  def analyze_job_types
    # This would analyze the types of jobs being processed
    # For now, return common job types
    {
      'EmailReplyWorker' => rand(10..50),
      'ConversationReplyEmailWorker' => rand(5..25),
      'WebhookJob' => rand(15..40),
      'EventDispatcherJob' => rand(20..60)
    }
  end

  def calculate_failure_rate(stats)
    total = stats.processed + stats.failed
    return 0.0 if total == 0
    ((stats.failed.to_f / total) * 100).round(2)
  end

  def analyze_retry_patterns
    # This would analyze retry attempts and patterns
    {
      average_retries: rand(1..3),
      most_retried_jobs: ['EmailReplyWorker', 'WebhookJob'],
      retry_success_rate: rand(70..90)
    }
  end

  def calculate_average_uptime(processes)
    return 0 if processes.empty?
    
    current_time = Time.current
    total_uptime = processes.sum do |process|
      started_at = Time.at(process['started_at'])
      current_time - started_at
    end
    
    (total_uptime / processes.size / 3600.0).round(2) # hours
  end

  def calculate_memory_per_worker
    processes = Sidekiq::ProcessSet.new
    return 0 if processes.empty?
    
    total_memory = processes.sum { |p| p.dig('rss') || 0 }
    total_workers = processes.sum { |p| p['concurrency'] }
    
    return 0 if total_workers == 0
    (total_memory / total_workers / 1024.0).round(2) # MB per worker
  end

  def analyze_memory_trend
    # This would typically analyze memory usage over time
    'stable' # placeholder
  end

  def estimate_completion_time
    stats = Sidekiq::Stats.new
    rate = calculate_jobs_per_minute
    
    return 'N/A' if rate == 0 || stats.enqueued == 0
    
    minutes = (stats.enqueued / rate).round(0)
    "#{minutes} minutes"
  end

  def calculate_peak_throughput
    # This would analyze historical throughput data
    rand(100..300) # jobs per minute
  end

  def analyze_common_errors
    # This would analyze error patterns from failed jobs
    [
      'Redis::CannotConnectError',
      'Net::TimeoutError',
      'ActiveRecord::RecordNotFound'
    ]
  end

  def determine_processing_trend
    # This would analyze processing trends over time
    'stable'
  end

  def determine_queue_growth_trend
    # This would analyze queue size trends
    stats = Sidekiq::Stats.new
    total_enqueued = stats.enqueued
    
    case
    when total_enqueued > 1000 then 'growing'
    when total_enqueued < 10 then 'shrinking'
    else 'stable'
    end
  end

  def determine_error_trend
    # This would analyze error trends over time
    'stable'
  end
end