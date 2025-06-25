# Local CDN Simulation for Development
# This simulates CDN behavior for better development-production parity

if Rails.env.development?
  # Custom middleware to simulate CDN behavior
  class LocalCDNSimulator
    def initialize(app)
      @app = app
    end
    
    def call(env)
      status, headers, response = @app.call(env)
      
      # Add CDN-like headers for asset requests
      if asset_request?(env['PATH_INFO'])
        headers['X-CDN-Cache'] = 'HIT-LOCAL'
        headers['X-CDN-Region'] = 'local-dev'
        headers['X-Served-By'] = 'kirvano-local-cdn'
        headers['Server-Timing'] = "cdn;dur=0.1"
        
        # Add CORS headers for cross-origin asset requests
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET, HEAD, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'Content-Type'
        
        # Optimize content type detection
        content_type = detect_content_type(env['PATH_INFO'])
        headers['Content-Type'] = content_type if content_type
      end
      
      [status, headers, response]
    end
    
    private
    
    def asset_request?(path)
      path_str = path.to_s
      path_str&.match?(/\/(assets|vite|packs)\//) || 
      path_str&.match?(/\.(js|css|png|jpg|jpeg|gif|svg|ico|webp|woff|woff2|eot|ttf|otf)$/)
    end
    
    def detect_content_type(path)
      path_str = path.to_s
      case path_str
      when /\.js$/
        'application/javascript; charset=utf-8'
      when /\.css$/
        'text/css; charset=utf-8'
      when /\.png$/
        'image/png'
      when /\.jpe?g$/
        'image/jpeg'
      when /\.gif$/
        'image/gif'
      when /\.svg$/
        'image/svg+xml'
      when /\.woff2$/
        'font/woff2'
      when /\.woff$/
        'font/woff'
      when /\.ttf$/
        'font/ttf'
      when /\.eot$/
        'application/vnd.ms-fontobject'
      else
        nil
      end
    end
  end
  
  # Configure Rails application with CDN simulation
  Rails.application.configure do
    # Simulate CDN behavior with local asset serving optimizations
    config.public_file_server.enabled = true
    config.public_file_server.index_name = 'index'
    
    # Enhanced caching headers for development assets (simulating CDN)
    config.public_file_server.headers = {
      # JavaScript and CSS assets
      /\.(js|css)$/ => {
        'Cache-Control' => 'public, max-age=3600',  # 1 hour cache
        'Vary' => 'Accept-Encoding',
        'X-CDN-Simulation' => 'local-dev'
      },
      
      # Font assets
      /\.(woff|woff2|eot|ttf|otf)$/ => {
        'Cache-Control' => 'public, max-age=86400',  # 24 hours
        'Access-Control-Allow-Origin' => '*',
        'X-CDN-Simulation' => 'local-dev'
      },
      
      # Image assets
      /\.(png|jpg|jpeg|gif|svg|ico|webp)$/ => {
        'Cache-Control' => 'public, max-age=7200',   # 2 hours
        'Vary' => 'Accept-Encoding',
        'X-CDN-Simulation' => 'local-dev'
      },
      
      # Vite assets (development)
      /\/vite\// => {
        'Cache-Control' => 'public, max-age=1800',   # 30 minutes
        'Access-Control-Allow-Origin' => '*',
        'X-CDN-Simulation' => 'local-dev'
      }
    }
    
    # Enable GZIP compression to simulate CDN compression
    config.middleware.use Rack::Deflater
    
    # Add middleware to simulate CDN headers and behavior
    config.middleware.insert_before ActionDispatch::Static, LocalCDNSimulator
  end
  
  # Development asset host configuration for CDN simulation
  Rails.application.config.action_controller.asset_host = proc do |source, request|
    # Simulate different CDN subdomains for parallel loading
    if request&.ssl?
      "https://cdn#{(source.hash % 4) + 1}.kirvano.local:3000"
    else
      "http://cdn#{(source.hash % 4) + 1}.kirvano.local:3000"
    end
  end if ENV['SIMULATE_CDN'] == 'true'
  
  # Add middleware to serve assets with optimal headers
  Rails.application.config.middleware.insert_before(
    ActionDispatch::Static,
    Rack::ConditionalGet
  )
  
  Rails.application.config.middleware.insert_before(
    ActionDispatch::Static,
    Rack::ETag
  )
end