# ref: https://github.com/rails/rails/issues/43906#issuecomment-1094380699
# https://github.com/rails/rails/issues/43906#issuecomment-1099992310
task before_assets_precompile: :environment do
  # Set production environment for optimal builds
  ENV['NODE_ENV'] = 'production'
  ENV['RAILS_ENV'] = 'production'
  
  Rails.logger.info 'Starting asset compilation for production...'
  
  # Install dependencies with frozen lockfile for reproducible builds
  Rails.logger.info 'Installing Node.js dependencies...'
  system('pnpm install --frozen-lockfile --prod=false') || raise('Failed to install Node.js dependencies')
  
  # Build SDK first (library mode)
  Rails.logger.info '-------------- Building SDK for Production --------------'
  system('pnpm run build:sdk') || raise('Failed to build SDK')
  
  # Build main application assets with Vite
  Rails.logger.info '-------------- Building App Assets for Production --------------'
  system('pnpm exec vite build') || raise('Failed to build app assets')
  
  Rails.logger.info 'Asset compilation completed successfully!'
end

# Asset optimization and compression task
task compress_assets: :environment do
  Rails.logger.info 'Compressing static assets...'
  
  # Compress JavaScript and CSS files
  Dir.glob('public/vite/assets/**/*.{js,css}').each do |file|
    next if file.end_with?('.gz')
    
    # Create gzip version
    system("gzip -c #{file} > #{file}.gz")
    Rails.logger.info "Compressed: #{file}"
  end
  
  Rails.logger.info 'Asset compression completed!'
end

# Clean up development assets and optimize for production
task optimize_assets: :environment do
  Rails.logger.info 'Optimizing assets for production...'
  
  # Remove development-only files
  FileUtils.rm_rf('public/vite-dev') if Dir.exist?('public/vite-dev')
  
  # Remove source maps in production if they exist
  if ENV['RAILS_ENV'] == 'production'
    Dir.glob('public/vite/assets/**/*.map').each do |map_file|
      FileUtils.rm(map_file)
      Rails.logger.info "Removed source map: #{map_file}"
    end
  end
  
  Rails.logger.info 'Asset optimization completed!'
end

# every time you execute 'rake assets:precompile'
# run 'before_assets_precompile' first, then optimize and compress
Rake::Task['assets:precompile'].enhance %w[before_assets_precompile]
Rake::Task['assets:precompile'].enhance do
  Rake::Task['optimize_assets'].invoke
  Rake::Task['compress_assets'].invoke
end
