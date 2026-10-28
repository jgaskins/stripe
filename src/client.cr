require "db/pool"
require "uri"
require "http/client"

require "./http_client"
require "./error"
require "./params_builder"

class Stripe::Client
  def initialize(
    @api_key = ENV["STRIPE_API_KEY"],
    @base_uri = URI.parse("https://api.stripe.com"),
    max_idle_pool_size : Int32 = 10,
    max_pool_size : Int32 = 10,
  )
    auth = "Bearer #{api_key}"
    options = DB::Pool::Options.new(
      max_idle_pool_size: max_idle_pool_size,
      max_pool_size: max_pool_size,
    )
    @http = DB::Pool(HTTPClient).new options do
      http = HTTPClient.new(base_uri)
      http.before_request do |request|
        request.headers["Authorization"] ||= auth
        request.headers["Stripe-Version"] ||= "2026-09-30.endive"
        request.headers["User-Agent"] ||= "https://github.com/jgaskins/stripe"
      end
      http
    end
  end

  {% for method in %w[get post put patch delete] %}
    {% replayable = %w[post put patch].includes? method %}
    def {{method.id}}(
      path : String,
      *,
      params : NamedTuple? = nil,
      {% if replayable %}
        idempotency_key : String? = nil,
      {% end %}
      as type : T.class,
    ) forall T
      if params
        resource = "#{path}?#{ParamsBuilder.from(params).to_s}"
      else
        resource = path
      end

      headers = HTTP::Headers.new
      {% if replayable %}
        headers["Idempotency-Key"] = idempotency_key if idempotency_key
      {% end %}

      error = nil
      2.times do
        @http.checkout do |http|
          response = http.{{method.id}}(resource, headers: headers)
          if response.success?
            return T.from_json(response.body)
          else
            raise RequestError.new(response.body)
          end
        rescue ex : IO::EOFError
          error = ex
          http.close
        end
      end

      raise error.not_nil!
    end

    def {{method.id}}(
      path : String,
      *,
      form : NamedTuple,
      {% if replayable %}
        idempotency_key : String? = nil,
      {% end %}
      as type : T.class,
    ) forall T
      headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded"}
      {% if replayable %}
        headers["Idempotency-Key"] = idempotency_key if idempotency_key
      {% end %}
      body = ParamsBuilder.from(form).to_s

      error = nil
      2.times do
        @http.checkout do |http|
          response = http.{{method.id}}(path, headers: headers, body: body)
          if response.success?
            return T.from_json(response.body)
          else
            raise RequestError.new(response.body)
          end
        rescue ex : IO::EOFError
          error = ex
          http.close
        end
      end

      raise error.not_nil!
    end
  {% end %}
end

class HTTP::Client
  private def io
    io = @io
    return io if io
    unless @reconnect
      raise "This HTTP::Client cannot be reconnected"
    end

    hostname = @host.starts_with?('[') && @host.ends_with?(']') ? @host[1..-2] : @host
    io = TCPSocket.new hostname, @port, @dns_timeout, @connect_timeout
    io.read_timeout = @read_timeout if @read_timeout
    io.write_timeout = @write_timeout if @write_timeout
    io.tcp_keepalive_count = 2
    io.tcp_keepalive_interval = 5
    io.tcp_keepalive_idle = 2
    io.sync = false

    {% if !flag?(:without_openssl) %}
      if tls = @tls
        tcp_socket = io
        begin
          io = OpenSSL::SSL::Socket::Client.new(tcp_socket, context: tls, sync_close: true, hostname: hostname.rchop('.'))
        rescue exc
          # don't leak the TCP socket when the SSL connection failed
          tcp_socket.close
          raise exc
        end
      end
    {% end %}

    @io = io
  end
end
