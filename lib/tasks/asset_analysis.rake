namespace :assets do
  desc 'Analyze bundle sizes and performance'
  task analyze: :environment do
    puts "\n🔍 Analyzing Asset Bundle Sizes..."
    puts "=" * 60
    
    # Analyze Vite assets
    vite_assets_path = Rails.root.join('public/vite/assets')
    if Dir.exist?(vite_assets_path)
      analyze_directory(vite_assets_path, 'Vite Assets')
    end
    
    # Analyze Sprockets assets
    sprockets_assets_path = Rails.root.join('public/assets')
    if Dir.exist?(sprockets_assets_path)
      analyze_directory(sprockets_assets_path, 'Sprockets Assets')
    end
    
    # Analyze SDK
    sdk_path = Rails.root.join('public/packs/js/sdk.js')
    if File.exist?(sdk_path)
      puts "\n📦 SDK Analysis:"
      puts "-" * 30
      analyze_file(sdk_path)
    end
    
    # Check for large assets that might need optimization
    puts "\n⚠️  Large Assets (>500KB):"
    puts "-" * 30
    large_assets = find_large_assets
    if large_assets.empty?
      puts "✅ No assets larger than 500KB found!"
    else
      large_assets.each { |asset| puts "  #{asset}" }
    end
    
    # Compression analysis
    puts "\n🗜️  Compression Analysis:"
    puts "-" * 30
    analyze_compression
    
    puts "\n✅ Analysis complete!"
  end
  
  desc 'Check asset optimization recommendations'
  task recommendations: :environment do
    puts "\n💡 Asset Optimization Recommendations:"
    puts "=" * 60
    
    # Check for unoptimized images
    check_image_optimization
    
    # Check for missing compression
    check_compression_setup
    
    # Check for CDN configuration
    check_cdn_setup
    
    # Check bundle splitting
    check_bundle_splitting
    
    puts "\n✅ Recommendations complete!"
  end
  
  private
  
  def analyze_directory(path, name)
    puts "\n📁 #{name}:"
    puts "-" * 30
    
    total_size = 0
    file_count = 0
    
    Dir.glob(File.join(path, '**', '*')).each do |file|
      next unless File.file?(file)
      
      size = File.size(file)
      total_size += size
      file_count += 1
      
      relative_path = file.sub(Rails.root.to_s + '/', '')
      puts "  #{format_size(size).rjust(10)} - #{relative_path}"
    end
    
    puts "  #{'-' * 40}"
    puts "  #{'Total:'.rjust(10)} #{format_size(total_size)} (#{file_count} files)"
  end
  
  def analyze_file(file_path)
    size = File.size(file_path)
    
    # Check if gzipped version exists
    gzipped_path = "#{file_path}.gz"
    if File.exist?(gzipped_path)
      gzipped_size = File.size(gzipped_path)
      compression_ratio = ((1 - gzipped_size.to_f / size) * 100).round(1)
      puts "  Original: #{format_size(size)}"
      puts "  Gzipped:  #{format_size(gzipped_size)} (#{compression_ratio}% compression)"
    else
      puts "  Size: #{format_size(size)} (no gzipped version found)"
    end
  end
  
  def find_large_assets
    large_assets = []
    threshold = 500 * 1024 # 500KB
    
    ['public/vite/assets', 'public/assets', 'public/packs'].each do |dir|
      path = Rails.root.join(dir)
      next unless Dir.exist?(path)
      
      Dir.glob(File.join(path, '**', '*')).each do |file|
        next unless File.file?(file)
        
        if File.size(file) > threshold
          relative_path = file.sub(Rails.root.to_s + '/', '')
          large_assets << "#{format_size(File.size(file))} - #{relative_path}"
        end
      end
    end
    
    large_assets
  end
  
  def analyze_compression
    compressed_count = 0
    uncompressed_count = 0
    
    ['public/vite/assets', 'public/assets'].each do |dir|
      path = Rails.root.join(dir)
      next unless Dir.exist?(path)
      
      Dir.glob(File.join(path, '**', '*.{js,css}')).each do |file|
        if File.exist?("#{file}.gz")
          compressed_count += 1
        else
          uncompressed_count += 1
        end
      end
    end
    
    total = compressed_count + uncompressed_count
    if total > 0
      percentage = (compressed_count.to_f / total * 100).round(1)
      puts "  Compressed: #{compressed_count}/#{total} files (#{percentage}%)"
    else
      puts "  No JS/CSS files found"
    end
  end
  
  def check_image_optimization
    puts "\n🖼️  Image Optimization:"
    
    image_dirs = ['public/vite/assets', 'public/assets', 'app/assets/images']
    large_images = []
    
    image_dirs.each do |dir|
      path = Rails.root.join(dir)
      next unless Dir.exist?(path)
      
      Dir.glob(File.join(path, '**', '*.{png,jpg,jpeg,gif}')).each do |file|
        size = File.size(file)
        if size > 100 * 1024 # 100KB
          relative_path = file.sub(Rails.root.to_s + '/', '')
          large_images << "  #{format_size(size)} - #{relative_path}"
        end
      end
    end
    
    if large_images.empty?
      puts "  ✅ No large images found"
    else
      puts "  ⚠️  Large images (>100KB) that could be optimized:"
      large_images.each { |img| puts img }
      puts "  💡 Consider using WebP format or image compression tools"
    end
  end
  
  def check_compression_setup
    puts "\n🗜️  Compression Setup:"
    
    if ENV['RAILS_ASSETS_COMPRESS'] == 'true'
      puts "  ✅ Asset compression is enabled"
    else
      puts "  ⚠️  Asset compression is not enabled"
      puts "  💡 Set RAILS_ASSETS_COMPRESS=true in production"
    end
  end
  
  def check_cdn_setup
    puts "\n🌐 CDN Configuration:"
    
    if ENV['ASSET_CDN_HOST'].present?
      puts "  ✅ CDN host configured: #{ENV['ASSET_CDN_HOST']}"
    else
      puts "  💡 Consider setting up a CDN with ASSET_CDN_HOST environment variable"
    end
  end
  
  def check_bundle_splitting
    puts "\n📦 Bundle Splitting:"
    
    vite_assets = Dir.glob(Rails.root.join('public/vite/assets/*.js'))
    if vite_assets.length > 5
      puts "  ✅ Multiple JS bundles detected (#{vite_assets.length} files)"
      puts "  💡 Good bundle splitting helps with caching"
    else
      puts "  ⚠️  Limited bundle splitting detected"
      puts "  💡 Consider implementing more granular code splitting"
    end
  end
  
  def format_size(bytes)
    units = ['B', 'KB', 'MB', 'GB']
    size = bytes.to_f
    unit_index = 0
    
    while size >= 1024 && unit_index < units.length - 1
      size /= 1024
      unit_index += 1
    end
    
    "#{size.round(1)} #{units[unit_index]}"
  end
end