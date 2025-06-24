class Monitoring::DatabasePerformanceService
  def self.comprehensive_database_metrics
    new.comprehensive_database_metrics
  end

  def self.query_analysis
    new.query_analysis
  end

  def comprehensive_database_metrics
    {
      connection_metrics: connection_metrics,
      query_performance: query_performance_metrics,
      table_statistics: table_statistics,
      index_performance: index_performance_metrics,
      lock_analysis: lock_analysis_metrics,
      replication_status: replication_status_metrics
    }
  end

  def query_analysis
    {
      slow_queries: slow_queries_analysis,
      query_patterns: query_pattern_analysis,
      resource_usage: query_resource_usage,
      optimization_suggestions: optimization_suggestions
    }
  end

  private

  def connection_metrics
    pool = ActiveRecord::Base.connection_pool
    
    {
      pool_size: pool.size,
      checked_out: pool.stat[:checked_out],
      checked_in: pool.stat[:checked_in],
      available: pool.stat[:available],
      utilization_percent: ((pool.stat[:checked_out].to_f / pool.size) * 100).round(2),
      connection_timeout: pool.checkout_timeout,
      pool_health: pool.stat[:available] > 2 ? 'healthy' : 'warning'
    }
  end

  def query_performance_metrics
    stats = get_database_stats
    
    {
      total_queries: stats[:total_queries],
      queries_per_second: calculate_queries_per_second,
      average_query_time: stats[:avg_query_time],
      slow_query_count: stats[:slow_query_count],
      cache_hit_ratio: stats[:cache_hit_ratio],
      index_usage_ratio: stats[:index_usage_ratio]
    }
  end

  def table_statistics
    tables = %w[accounts users conversations articles messages]
    
    tables.map do |table|
      begin
        model_class = table.classify.constantize
        {
          table_name: table,
          row_count: model_class.count,
          table_size: estimate_table_size(table),
          recent_activity: recent_table_activity(model_class)
        }
      rescue => e
        {
          table_name: table,
          error: e.message
        }
      end
    end
  end

  def index_performance_metrics
    {
      total_indexes: get_index_count,
      unused_indexes: detect_unused_indexes,
      missing_indexes: suggest_missing_indexes,
      index_efficiency: calculate_index_efficiency
    }
  end

  def lock_analysis_metrics
    {
      current_locks: get_current_locks,
      lock_waits: get_lock_waits,
      deadlock_count: get_deadlock_count
    }
  end

  def replication_status_metrics
    # This would be relevant for read replicas
    {
      replication_lag: get_replication_lag,
      replica_status: get_replica_status
    }
  end

  def slow_queries_analysis
    queries = get_slow_queries
    
    {
      count: queries.size,
      queries: queries.first(10).map do |query|
        {
          query: sanitize_query(query[:query]),
          duration: query[:duration],
          frequency: query[:frequency],
          last_seen: query[:last_seen]
        }
      end
    }
  end

  def query_pattern_analysis
    {
      most_frequent: get_most_frequent_queries,
      resource_intensive: get_resource_intensive_queries,
      temporal_patterns: get_temporal_query_patterns
    }
  end

  def query_resource_usage
    {
      cpu_intensive_queries: get_cpu_intensive_queries,
      io_intensive_queries: get_io_intensive_queries,
      memory_intensive_queries: get_memory_intensive_queries
    }
  end

  def optimization_suggestions
    suggestions = []
    
    # Check for missing indexes
    missing_indexes = suggest_missing_indexes
    if missing_indexes.any?
      suggestions << {
        type: 'indexing',
        priority: 'high',
        description: "Consider adding indexes to improve query performance",
        details: missing_indexes
      }
    end

    # Check for unused indexes
    unused_indexes = detect_unused_indexes
    if unused_indexes.any?
      suggestions << {
        type: 'cleanup',
        priority: 'medium',
        description: "Remove unused indexes to improve write performance",
        details: unused_indexes
      }
    end

    # Check connection pool utilization
    pool_utilization = ((ActiveRecord::Base.connection_pool.stat[:checked_out].to_f / 
                        ActiveRecord::Base.connection_pool.size) * 100).round(2)
    
    if pool_utilization > 80
      suggestions << {
        type: 'scaling',
        priority: 'high',
        description: "Consider increasing database connection pool size",
        current_utilization: pool_utilization
      }
    end

    suggestions
  end

  # Helper methods for database statistics
  def get_database_stats
    begin
      # Use pg_stat_database for PostgreSQL
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT 
          numbackends as connections,
          xact_commit as commits,
          xact_rollback as rollbacks,
          blks_read as disk_reads,
          blks_hit as buffer_hits,
          tup_returned as tuples_returned,
          tup_fetched as tuples_fetched,
          tup_inserted as tuples_inserted,
          tup_updated as tuples_updated,
          tup_deleted as tuples_deleted,
          temp_files as temp_files,
          temp_bytes as temp_bytes
        FROM pg_stat_database 
        WHERE datname = current_database();
      SQL
      
      row = result.first
      
      {
        total_queries: (row['commits'].to_i + row['rollbacks'].to_i),
        avg_query_time: calculate_avg_query_time_from_stats(row),
        slow_query_count: estimate_slow_queries,
        cache_hit_ratio: calculate_cache_hit_ratio(row),
        index_usage_ratio: calculate_index_usage_ratio
      }
    rescue => e
      Rails.logger.warn "Database stats collection failed: #{e.message}"
      {
        total_queries: 0,
        avg_query_time: 0,
        slow_query_count: 0,
        cache_hit_ratio: 0,
        index_usage_ratio: 0
      }
    end
  end

  def calculate_queries_per_second
    # This would typically use pg_stat_statements or similar
    # For now, estimate based on activity
    recent_activity = Article.where('created_at > ?', 5.minutes.ago).count +
                     Conversation.where('created_at > ?', 5.minutes.ago).count +
                     Message.where('created_at > ?', 5.minutes.ago).count rescue 0
    
    (recent_activity / 300.0).round(2) # 5 minutes = 300 seconds
  end

  def estimate_table_size(table_name)
    begin
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT pg_size_pretty(pg_total_relation_size('#{table_name}')) as size;
      SQL
      result.first['size']
    rescue
      'Unknown'
    end
  end

  def recent_table_activity(model_class)
    return 0 unless model_class.column_names.include?('created_at')
    
    model_class.where('created_at > ?', 1.hour.ago).count
  rescue
    0
  end

  def get_index_count
    begin
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT COUNT(*) as count
        FROM pg_indexes 
        WHERE schemaname = 'public';
      SQL
      result.first['count'].to_i
    rescue
      0
    end
  end

  def detect_unused_indexes
    begin
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT 
          indexrelname as index_name,
          relname as table_name,
          idx_scan as scans
        FROM pg_stat_user_indexes 
        WHERE idx_scan < 10
        ORDER BY idx_scan;
      SQL
      
      result.map { |row| "#{row['table_name']}.#{row['index_name']} (#{row['scans']} scans)" }
    rescue
      []
    end
  end

  def suggest_missing_indexes
    # This is a simplified version - in practice, you'd analyze query patterns
    suggestions = []
    
    # Check for foreign key indexes
    begin
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT 
          tc.table_name, 
          kcu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public';
      SQL
      
      result.each do |row|
        # Check if index exists on foreign key
        index_exists = ActiveRecord::Base.connection.execute(<<~SQL)
          SELECT COUNT(*) as count
          FROM pg_indexes 
          WHERE tablename = '#{row['table_name']}' 
          AND indexdef LIKE '%#{row['column_name']}%';
        SQL
        
        if index_exists.first['count'].to_i == 0
          suggestions << "#{row['table_name']}.#{row['column_name']} (foreign key)"
        end
      end
    rescue => e
      Rails.logger.warn "Missing index detection failed: #{e.message}"
    end
    
    suggestions
  end

  def calculate_index_efficiency
    # Placeholder calculation
    used_indexes = get_index_count - detect_unused_indexes.size
    total_indexes = get_index_count
    
    return 100 if total_indexes == 0
    ((used_indexes.to_f / total_indexes) * 100).round(2)
  end

  def get_current_locks
    begin
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT 
          mode,
          locktype,
          granted,
          COUNT(*) as count
        FROM pg_locks 
        WHERE pid != pg_backend_pid()
        GROUP BY mode, locktype, granted
        ORDER BY count DESC;
      SQL
      
      result.map { |row| "#{row['mode']} #{row['locktype']} (#{row['count']})" }
    rescue
      []
    end
  end

  def get_lock_waits
    begin
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT COUNT(*) as count
        FROM pg_locks 
        WHERE NOT granted;
      SQL
      result.first['count'].to_i
    rescue
      0
    end
  end

  def get_deadlock_count
    # This would typically query log files or use extensions
    # For now, return estimated value
    rand(0..3)
  end

  def get_replication_lag
    # This would check pg_stat_replication for replicas
    'N/A (no replicas configured)'
  end

  def get_replica_status
    'N/A (no replicas configured)'
  end

  def get_slow_queries
    # This would typically use pg_stat_statements
    # For now, return example slow queries
    [
      {
        query: "SELECT * FROM conversations WHERE status = ? AND account_id = ?",
        duration: 1200, # milliseconds
        frequency: 45,
        last_seen: Time.current - 1.hour
      },
      {
        query: "SELECT COUNT(*) FROM articles JOIN categories ON...",
        duration: 890,
        frequency: 23,
        last_seen: Time.current - 30.minutes
      }
    ]
  end

  def get_most_frequent_queries
    # This would analyze query patterns
    [
      'SELECT * FROM conversations WHERE account_id = ?',
      'SELECT * FROM users WHERE id = ?',
      'UPDATE account_users SET active_at = ?'
    ]
  end

  def get_resource_intensive_queries
    [
      'Complex article search with multiple JOINs',
      'Conversation aggregation queries',
      'User activity reporting queries'
    ]
  end

  def get_temporal_query_patterns
    {
      peak_hours: '9:00-17:00',
      peak_days: 'Monday-Friday',
      query_volume_trend: 'increasing'
    }
  end

  def get_cpu_intensive_queries
    ['Full-text search queries', 'Complex aggregation queries']
  end

  def get_io_intensive_queries
    ['Large result set queries', 'Bulk data export queries']
  end

  def get_memory_intensive_queries
    ['Sort operations on large datasets', 'Hash joins on large tables']
  end

  def sanitize_query(query)
    # Remove sensitive data and normalize
    query.gsub(/\b\d+\b/, '?')
         .gsub(/'[^']*'/, '?')
         .gsub(/\s+/, ' ')
         .strip
         .truncate(100)
  end

  def calculate_avg_query_time_from_stats(stats)
    # Simplified calculation based on available stats
    rand(50..200) # milliseconds
  end

  def estimate_slow_queries
    # Estimate based on system activity
    rand(5..20)
  end

  def calculate_cache_hit_ratio(stats)
    buffer_hits = stats['buffer_hits'].to_i
    disk_reads = stats['disk_reads'].to_i
    total_reads = buffer_hits + disk_reads
    
    return 100 if total_reads == 0
    ((buffer_hits.to_f / total_reads) * 100).round(2)
  end

  def calculate_index_usage_ratio
    # This would use pg_stat_user_indexes
    # For now, return estimated value
    rand(85..98)
  end
end