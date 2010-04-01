require 'digest/md5'
require 'net/http'

module SimpleFacebook
  class Session
    class FacebookServerError < RuntimeError; end
    
    def initialize(api_key, api_secret, session_key = nil)
      @api_key = api_key
      @api_secret = api_secret
      @session_key = session_key
    end
    
    def facebook_call(method, args)
      args = {
        :method => method,
        :api_key => @api_key,
        :session_key => @session_key,
        :call_id => Time.now.to_i,
        :v => '1.0',
        :format => 'JSON'
      }.merge(args)
      
      args[:sig] = sign_args(args.stringify_keys)
      
      JSON.parse(post(args.symbolize_keys))
    end
    
    protected
    
    def method_missing(method, *args)
      method_parts = method.to_s.split('_')
      method = "#{method_parts.shift}.#{method_parts.shift}#{method_parts.join('_').camelize}"
      facebook_call(method, *args)
    end
    
    def sign_args(args)
      arg_string = args.map { |k, v| "#{k}=#{v}"}.sort.join('')
      Digest::MD5.hexdigest("#{arg_string}#{@api_secret}")
    end
    
    def post(args)
      uri = URI.parse('http://api.facebook.com/restserver.php')
      
      response        = nil
      post            = Net::HTTP::Post.new(uri.path)
      post.form_data  = args
      @connection     = Net::HTTP.new(uri.host, uri.port) 
      body = @connection.start { |http| response = http.request(post) }.body
      raise FacebookServerError if response && (response.code =~ /5../)
      body
    rescue FacebookServerError, Errno::EPIPE, Errno::ETIMEDOUT, Errno::EINVAL, Errno::ECONNRESET, EOFError, SocketError
      attempts == 3 ? raise : (attempts += 1; retry)
    end
  end
end