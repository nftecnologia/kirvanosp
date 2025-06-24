# Kirvano Production Health & Monitoring Report

## Overview

This document provides comprehensive monitoring and health check configurations implemented for the Kirvano application deployed on Railway. The monitoring system ensures production stability, performance tracking, and proactive issue detection.

## Health Check Endpoints

### Primary Health Check
- **Endpoint**: `/health`
- **Purpose**: Comprehensive system health validation
- **Response**: JSON with detailed service status
- **Checks**:
  - Database connectivity and performance
  - Redis connectivity and memory usage
  - Sidekiq worker status and queue health
  - Active Storage functionality
  - Memory usage monitoring
  - Application-specific metrics

### Basic Status Check
- **Endpoint**: `/api`
- **Purpose**: Quick service status for basic monitoring
- **Response**: Version, timestamp, and basic service status

## Monitoring Endpoints

All monitoring endpoints require administrator authentication and are located under `/api/v1/monitoring/`:

### 1. General Metrics (`/api/v1/monitoring/metrics`)
Provides comprehensive application performance metrics:
- **Performance Metrics**: Response times, memory usage, cache performance
- **Business Metrics**: Articles, conversations, users, accounts statistics
- **Infrastructure Metrics**: Database connections, Redis stats, Sidekiq status
- **Security Metrics**: Failed logins, API security events

### 2. Active Alerts (`/api/v1/monitoring/alerts`)
Real-time system alerts and warnings:
- **Active Alerts**: Critical issues requiring immediate attention
- **Recent Incidents**: System incidents and their status
- **System Warnings**: Non-critical issues that need monitoring

### 3. Database Performance (`/api/v1/monitoring/database_performance`)
Detailed database performance analysis:
- **Connection Metrics**: Pool utilization, connection health
- **Query Performance**: Average times, slow query detection
- **Table Statistics**: Row counts, size analysis
- **Index Performance**: Usage analysis, optimization suggestions
- **Lock Analysis**: Current locks, deadlock detection

### 4. Article Metrics (`/api/v1/monitoring/article_metrics`)
Kirvano-specific article creation monitoring:
- **Health Metrics**: Creation status, content quality, user engagement
- **Performance Metrics**: Creation rates, publication rates, error tracking
- **Content Analysis**: Quality scores, engagement metrics
- **System Performance**: Database performance for article operations

### 5. Sidekiq Metrics (`/api/v1/monitoring/sidekiq_metrics`)
Background job processing monitoring:
- **Comprehensive Metrics**: Queues, workers, jobs, processes
- **Health Status**: Queue health, alerts, recommendations
- **Performance Analysis**: Throughput, latency, error analysis, trends

### 6. Uptime Status (`/api/v1/monitoring/uptime_status`)
External service and uptime monitoring:
- **External Services**: API endpoints, email service, webhook service, CDN
- **Uptime Metrics**: Application uptime, service availability, SLA tracking
- **Dependencies**: Critical vs. optional services, dependency graph

## Railway Health Check Configuration

The `railway.yml` file includes comprehensive health checks:

### Web Service Health Check
```yaml
healthcheck:
  path: /health
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
  successThreshold: 1
```

### Worker Service Health Check
```yaml
healthcheck:
  command: ["bundle", "exec", "ruby", "-e", "require 'sidekiq/api'; exit(Sidekiq::ProcessSet.new.size > 0 ? 0 : 1)"]
  initialDelaySeconds: 30
  periodSeconds: 30
  timeoutSeconds: 10
  failureThreshold: 3
  successThreshold: 1
```

## Error Tracking & Alerting

### Sentry Integration
Enhanced Sentry configuration provides:
- **Performance Monitoring**: Request tracing and profiling
- **Error Filtering**: Excludes common non-critical errors
- **Custom Tags**: Environment, version, component tagging
- **User Context**: Automatic user and account context
- **Custom Fingerprinting**: Better error grouping for Redis and database errors

### Alert Thresholds
- **Database Connections**: Alert when available connections < 2
- **Redis Memory**: Warning when usage > 500MB
- **Sidekiq Queues**: Warning when enqueued > 1000 jobs
- **Failed Jobs**: Critical when failed jobs > 100
- **Queue Latency**: Alert when latency > 300 seconds

## Monitoring Services

### Article Metrics Service
- **Creation Monitoring**: Track article creation rates and trends
- **Quality Analysis**: Content quality scoring and metrics
- **Performance Tracking**: Database query performance for articles
- **Error Detection**: Invalid or problematic article detection

### Database Performance Service
- **Connection Pool Monitoring**: Track pool utilization and health
- **Query Analysis**: Slow query detection and optimization suggestions
- **Index Performance**: Usage analysis and recommendations
- **Table Statistics**: Growth tracking and size monitoring

### Sidekiq Monitoring Service
- **Queue Health**: Real-time queue status and alerts
- **Worker Distribution**: Track worker allocation across queues
- **Performance Analysis**: Throughput, latency, and error analysis
- **Memory Tracking**: Worker memory usage monitoring

### Uptime Monitoring Service
- **External Service Checks**: Monitor external API dependencies
- **SLA Tracking**: Calculate uptime percentages and SLA compliance
- **Dependency Mapping**: Visualize service dependencies
- **Response Time Analysis**: Track external service performance

## Key Metrics Tracked

### Application Metrics
- Response times (average, P95)
- Requests per minute
- Memory usage (heap size, GC stats)
- Cache hit/miss rates

### Business Metrics
- Article creation/publication rates
- Conversation volume and resolution times
- User activity and engagement
- Account growth and status

### Infrastructure Metrics
- Database connection pool utilization
- Redis memory usage and performance
- Sidekiq queue health and processing rates
- Storage usage and file counts

### Security Metrics
- Failed login attempts
- Blocked/rate-limited requests
- API security events
- Geographic access patterns

## Dashboard Recommendations

### Primary Dashboard
1. **System Health**: Overall status, uptime, active alerts
2. **Performance**: Response times, throughput, error rates
3. **Infrastructure**: Database, Redis, Sidekiq status
4. **Business**: Article creation, conversations, user activity

### Detailed Dashboards
1. **Database Performance**: Query times, connection pool, slow queries
2. **Sidekiq Operations**: Queue status, worker performance, job trends
3. **Article Analytics**: Creation patterns, quality metrics, user engagement
4. **Security Monitoring**: Authentication patterns, blocked requests, anomalies

## Alert Configuration

### Critical Alerts (Immediate Response)
- Application down (health check failures)
- Database connection failures
- Redis connection failures
- No Sidekiq workers running
- High job failure rates (>5%)

### Warning Alerts (Monitor Closely)
- High queue sizes (>500 jobs)
- Slow response times (>1s average)
- High memory usage (>80% of available)
- Low database connection pool availability

### Informational Alerts
- Queue latency increases
- Content quality score decreases
- Unusual user activity patterns
- External service degradation

## Maintenance Recommendations

### Daily Monitoring
- Check overall system health via `/health` endpoint
- Review active alerts and system warnings
- Monitor Sidekiq queue sizes and processing rates
- Check article creation metrics and trends

### Weekly Analysis
- Review database performance and optimization suggestions
- Analyze Sidekiq performance trends and worker allocation
- Check uptime SLA compliance and external service health
- Review error patterns and implement fixes

### Monthly Reports
- Generate comprehensive performance reports
- Analyze business metric trends
- Review and update alert thresholds
- Plan infrastructure scaling based on growth patterns

## Environment Variables for Monitoring

```bash
# Error Tracking
SENTRY_DSN=your_sentry_dsn
SENTRY_TRACES_SAMPLE_RATE=0.1
SENTRY_PROFILES_SAMPLE_RATE=0.1

# Performance Monitoring
NEW_RELIC_LICENSE_KEY=your_license_key
NEW_RELIC_APP_NAME=Kirvano Production

# External Services
FRONTEND_URL=https://your-domain.com
ASSET_CDN_HOST=cdn.your-domain.com

# Railway Specific
RAILWAY_GIT_COMMIT_SHA=auto_populated
RAILWAY_ENVIRONMENT=production
```

## Security Considerations

- All monitoring endpoints require administrator authentication
- Sensitive data is excluded from error reports unless explicitly configured
- External service checks use timeouts to prevent hanging
- Health check endpoints use minimal database queries to avoid impact

## Next Steps

1. **Set up External Monitoring**: Configure services like Pingdom or UptimeRobot
2. **Implement Log Aggregation**: Set up centralized logging with structured data
3. **Create Custom Dashboards**: Build visual dashboards using the monitoring API
4. **Automate Alerting**: Configure PagerDuty or similar for critical alerts
5. **Performance Baseline**: Establish performance baselines for key metrics

This monitoring system provides comprehensive visibility into the Kirvano application's health, performance, and business metrics, enabling proactive maintenance and rapid issue resolution in production.