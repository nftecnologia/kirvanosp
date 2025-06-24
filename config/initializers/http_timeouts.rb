# HTTP Timeout Configuration for Development Performance
if Rails.env.development?
  # Configure HTTParty global timeout
  class HTTParty::Request
    alias_method :original_perform, :perform
    
    def perform(&block)
      # Add default timeout if not specified
      @options[:timeout] ||= 10
      @options[:open_timeout] ||= 5
      original_perform(&block)
    end
  end

  # Configure RestClient global timeout
  RestClient::Request.class_eval do
    alias_method :original_execute, :execute
    
    def self.execute(args, &block)
      # Add default timeout if not specified
      args[:timeout] ||= 10
      args[:open_timeout] ||= 5
      original_execute(args, &block)
    end
  end

  # Configure Net::HTTP global timeout
  Net::HTTP.class_eval do
    alias_method :original_start, :start
    
    def start
      # Set default timeouts for Net::HTTP
      self.open_timeout ||= 5
      self.read_timeout ||= 10
      original_start
    end
  end
end