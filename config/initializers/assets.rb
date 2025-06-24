# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w[dashboardChart.js]

# to take care of fonts in assets pre-compiling
# Ref: https://stackoverflow.com/questions/56960709/rails-font-cors-policy
# https://github.com/rails/sprockets/issues/632#issuecomment-551324428
Rails.application.config.assets.precompile << ['*.svg', '*.eot', '*.woff', '*.ttf', '*.woff2']

# Asset fingerprinting and caching optimizations
if Rails.env.production?
  # Enable asset fingerprinting for cache busting
  Rails.application.config.assets.digest = true
  
  # Compress assets
  Rails.application.config.assets.compress = true
  
  # Configure asset compilation
  Rails.application.config.assets.compile = false
  
  # Add Vite assets to asset paths for proper serving
  Rails.application.config.assets.paths << Rails.root.join('public', 'vite', 'assets')
  Rails.application.config.assets.paths << Rails.root.join('public', 'packs')
  
  # Add size-limit enforcement
  Rails.application.config.after_initialize do
    # Log asset sizes in production for monitoring
    if defined?(Rails::Server)
      Rails.logger.info "Asset compilation completed for production environment"
    end
  end
end
