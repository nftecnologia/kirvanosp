# Asset optimization configuration for production
if Rails.env.production?
  # Configure asset compression
  Rails.application.config.assets.gzip = true
  
  # Set optimal cache headers for different asset types
  Rails.application.config.public_file_server.headers = {
    # Assets with hash - long cache
    /\.(js|css)-[a-f0-9]{8}\./ => {
      'Cache-Control' => 'public, max-age=31536000, immutable',
      'Vary' => 'Accept-Encoding'
    },
    # Fonts
    /\.(woff|woff2|eot|ttf|otf)$/ => {
      'Cache-Control' => 'public, max-age=31536000',
      'Access-Control-Allow-Origin' => '*'
    },
    # Images
    /\.(png|jpg|jpeg|gif|svg|ico|webp)$/ => {
      'Cache-Control' => 'public, max-age=2592000', # 30 days
      'Vary' => 'Accept-Encoding'
    },
    # Default for other assets
    // => {
      'Cache-Control' => 'public, max-age=86400', # 1 day
      'Vary' => 'Accept-Encoding'
    }
  }
  
  # Configure asset host for CDN if available
  if ENV['ASSET_CDN_HOST'].present?
    Rails.application.config.action_controller.asset_host = ENV['ASSET_CDN_HOST']
    
    # Enable CORS for cross-origin assets
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV['ASSET_CDN_HOST']
        resource '/assets/*', headers: :any, methods: [:get, :head, :options]
        resource '/vite/*', headers: :any, methods: [:get, :head, :options]
        resource '/packs/*', headers: :any, methods: [:get, :head, :options]
      end
    end
  end
end

# Development optimizations
if Rails.env.development?
  # Enable source maps for better debugging
  Rails.application.config.assets.debug = true
end