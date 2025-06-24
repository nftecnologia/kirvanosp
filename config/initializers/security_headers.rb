# Security Headers Configuration for Production Domain
Rails.application.configure do
  # Add security headers middleware
  config.middleware.use Rack::Deflater
  
  # Security headers for production
  if Rails.env.production?
    config.middleware.insert_before 0, Rack::Attack
    
    # Add security headers
    config.middleware.insert_before ActionDispatch::Static, Proc.new { |env|
      # Get response from the next middleware
      status, headers, response = env['app'].call(env)
      
      # Add security headers
      headers.merge!({
        'X-Frame-Options' => 'DENY',
        'X-Content-Type-Options' => 'nosniff',
        'X-XSS-Protection' => '1; mode=block',
        'Referrer-Policy' => 'strict-origin-when-cross-origin',
        'Permissions-Policy' => 'camera=(), microphone=(), geolocation=()',
        'X-Permitted-Cross-Domain-Policies' => 'none'
      })
      
      [status, headers, response]
    }
  end
end