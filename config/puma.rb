# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
# Enhanced thread configuration for development performance
if Rails.env.development?
  max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 3)  # Reduced for development
  min_threads_count = ENV.fetch('RAILS_MIN_THREADS', 1)  # Start with fewer threads
else
  max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
  min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
end

threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch('PORT', 3000)

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV') { 'development' }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch('WEB_CONCURRENCY', 0)

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Development-specific Puma optimizations
if Rails.env.development?
  # Reduce worker timeout for faster restarts
  worker_timeout 60
  
  # Optimize for development workloads
  worker_shutdown_timeout 30
  
  # Enable faster restarts
  prune_bundler
  
  # Add request timeout for hanging requests in development
  if defined?(Rack::Timeout)
    # Ensure request timeout is reasonable for development
    rackup_opts = { timeout: 30, wait_timeout: 5 }
  end
  
  # Development-specific callbacks
  on_worker_boot do
    # Optimize database connections for development
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  end
  
  on_restart do
    puts "Puma restarting for development..."
  end
else
  # Production settings
  worker_timeout 30
  worker_shutdown_timeout 15
end
