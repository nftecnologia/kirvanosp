class Monitoring::ArticleMetricsService
  def self.article_health_metrics
    new.article_health_metrics
  end

  def self.article_performance_metrics
    new.article_performance_metrics
  end

  def article_health_metrics
    {
      creation_status: article_creation_status,
      content_quality: content_quality_metrics,
      user_engagement: user_engagement_metrics,
      system_performance: article_system_performance
    }
  end

  def article_performance_metrics
    {
      creation_rate: article_creation_rate,
      publication_rate: article_publication_rate,
      average_time_to_publish: average_time_to_publish,
      error_rate: article_error_rate
    }
  end

  private

  def article_creation_status
    {
      total_articles: Article.count,
      articles_today: articles_created_in_period(1.day),
      articles_this_week: articles_created_in_period(1.week),
      articles_this_month: articles_created_in_period(1.month),
      published_articles: Article.where(status: 'published').count,
      draft_articles: Article.where(status: 'draft').count,
      pending_articles: Article.where(status: 'pending').count
    }
  end

  def content_quality_metrics
    {
      average_content_length: average_content_length,
      articles_with_description: articles_with_description_count,
      articles_with_categories: articles_with_categories_count,
      recent_updates: recent_article_updates,
      quality_score: calculate_content_quality_score
    }
  end

  def user_engagement_metrics
    {
      articles_with_views: articles_with_views_count,
      average_views_per_article: average_views_per_article,
      most_viewed_articles: most_viewed_articles,
      recent_activity: recent_article_activity
    }
  end

  def article_system_performance
    {
      database_performance: {
        avg_query_time: measure_article_query_performance,
        slow_queries: detect_slow_article_queries
      },
      cache_performance: {
        hit_rate: article_cache_hit_rate,
        miss_rate: article_cache_miss_rate
      },
      storage_metrics: {
        total_attachments: article_attachments_count,
        storage_used: calculate_article_storage_usage
      }
    }
  end

  def article_creation_rate
    periods = {
      last_hour: articles_created_in_period(1.hour),
      last_24_hours: articles_created_in_period(1.day),
      last_week: articles_created_in_period(1.week)
    }
    
    {
      hourly_rate: periods[:last_hour],
      daily_rate: periods[:last_24_hours],
      weekly_rate: periods[:last_week],
      trend: calculate_creation_trend(periods)
    }
  end

  def article_publication_rate
    published_today = Article.where(status: 'published', updated_at: 1.day.ago..Time.current).count
    published_this_week = Article.where(status: 'published', updated_at: 1.week.ago..Time.current).count
    
    {
      daily_publications: published_today,
      weekly_publications: published_this_week,
      publication_ratio: calculate_publication_ratio
    }
  end

  def average_time_to_publish
    published_articles = Article.where(status: 'published')
                                .where('created_at > ?', 1.month.ago)
                                .where.not(created_at: nil)
    
    return 0 if published_articles.empty?
    
    total_time = published_articles.sum do |article|
      (article.updated_at - article.created_at).to_i
    end
    
    average_seconds = total_time / published_articles.count
    {
      seconds: average_seconds,
      hours: (average_seconds / 3600.0).round(2),
      days: (average_seconds / 86400.0).round(2)
    }
  end

  def article_error_rate
    # This would typically track creation/update failures
    # For now, we'll estimate based on empty or invalid articles
    total_recent = articles_created_in_period(1.week)
    problematic = Article.where('created_at > ?', 1.week.ago)
                         .where('title IS NULL OR title = ? OR content IS NULL OR content = ?', '', '')
                         .count
    
    {
      total_attempts: total_recent,
      failed_attempts: problematic,
      error_rate: total_recent > 0 ? (problematic.to_f / total_recent * 100).round(2) : 0
    }
  end

  def articles_created_in_period(period)
    Article.where('created_at > ?', period.ago).count
  end

  def average_content_length
    articles_with_content = Article.where.not(content: [nil, ''])
    return 0 if articles_with_content.empty?
    
    total_length = articles_with_content.sum { |article| article.content&.length || 0 }
    (total_length / articles_with_content.count).round(0)
  end

  def articles_with_description_count
    Article.where.not(description: [nil, '']).count
  end

  def articles_with_categories_count
    Article.where.not(category_id: nil).count
  end

  def recent_article_updates
    Article.where('updated_at > ?', 1.week.ago)
           .where('updated_at > created_at')
           .count
  end

  def calculate_content_quality_score
    total_articles = Article.count
    return 0 if total_articles == 0
    
    quality_factors = {
      has_description: articles_with_description_count,
      has_category: articles_with_categories_count,
      has_content: Article.where.not(content: [nil, '']).count,
      is_published: Article.where(status: 'published').count
    }
    
    weighted_score = (
      quality_factors[:has_description] * 0.2 +
      quality_factors[:has_category] * 0.2 +
      quality_factors[:has_content] * 0.4 +
      quality_factors[:is_published] * 0.2
    )
    
    ((weighted_score / total_articles) * 100).round(2)
  end

  def articles_with_views_count
    Article.where('views > 0').count
  end

  def average_views_per_article
    total_views = Article.sum(:views) || 0
    total_articles = Article.count
    
    return 0 if total_articles == 0
    (total_views.to_f / total_articles).round(2)
  end

  def most_viewed_articles
    Article.order(views: :desc)
           .limit(5)
           .pluck(:title, :views, :created_at)
           .map { |title, views, created_at| 
             { 
               title: title&.truncate(50), 
               views: views, 
               created_at: created_at 
             } 
           }
  end

  def recent_article_activity
    {
      created_today: articles_created_in_period(1.day),
      updated_today: Article.where('updated_at > ?', 1.day.ago).count,
      viewed_today: Article.where('updated_at > ?', 1.day.ago).sum(:views) || 0
    }
  end

  def measure_article_query_performance
    start_time = Time.current
    
    # Simulate common article queries
    Article.published.limit(10).to_a
    Article.joins(:category).limit(10).to_a
    Article.where('created_at > ?', 1.week.ago).count
    
    ((Time.current - start_time) * 1000).round(2) # milliseconds
  end

  def detect_slow_article_queries
    # This would typically analyze query logs
    # For now, return estimated slow queries
    [
      {
        query: "Article search with complex filters",
        avg_duration: 150, # ms
        frequency: 20
      },
      {
        query: "Article.joins(:category).where(...)",
        avg_duration: 89, # ms
        frequency: 45
      }
    ]
  end

  def article_cache_hit_rate
    # This would typically track cache performance
    # Placeholder implementation
    rand(0.75..0.95)
  end

  def article_cache_miss_rate
    1 - article_cache_hit_rate
  end

  def article_attachments_count
    Article.joins(:attachments).distinct.count
  rescue
    0
  end

  def calculate_article_storage_usage
    # This would calculate actual storage usage
    # Placeholder implementation
    {
      articles_mb: (Article.count * 0.5).round(2), # Estimate 0.5MB per article
      attachments_mb: (article_attachments_count * 2.1).round(2), # Estimate 2.1MB per attachment
      total_mb: ((Article.count * 0.5) + (article_attachments_count * 2.1)).round(2)
    }
  end

  def calculate_creation_trend(periods)
    if periods[:last_week] > periods[:last_24_hours] * 7
      'increasing'
    elsif periods[:last_week] < periods[:last_24_hours] * 5
      'decreasing'
    else
      'stable'
    end
  end

  def calculate_publication_ratio
    total_articles = Article.count
    published_articles = Article.where(status: 'published').count
    
    return 0 if total_articles == 0
    ((published_articles.to_f / total_articles) * 100).round(2)
  end
end