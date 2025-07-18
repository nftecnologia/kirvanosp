# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data, 'https://fonts.gstatic.com'
  policy.img_src     :self, :https, :data, 'https://images.unsplash.com', 'https://via.placeholder.com'
  policy.object_src  :none
  policy.script_src  :self, :https, 'https://js.stripe.com', 'https://cdn.jsdelivr.net'
  
  # Allow @vite/client to hot reload javascript changes in development
  policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }" if Rails.env.development?
  # You may need to enable this in production as well depending on your setup.
  policy.script_src *policy.script_src, :blob if Rails.env.test?
  
  policy.style_src   :self, :https, 'https://fonts.googleapis.com'
  # Allow @vite/client to hot reload style changes in development
  policy.style_src *policy.style_src, :unsafe_inline if Rails.env.development?
  
  # WebSocket connections for ActionCable
  policy.connect_src :self, :https, 'wss://kirvano.com', 'wss://app.kirvano.com'
  # Allow @vite/client to hot reload changes in development
  policy.connect_src *policy.connect_src, "ws://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

  # Specify URI for violation reports (optional)
  # policy.report_uri "/csp-violation-report-endpoint"
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
