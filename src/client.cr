require "http_client"
require "uri"

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
    params = URI::Params{
      "max_idle_pool_size" => max_idle_pool_size.to_s,
      "max_pool_size"      => max_pool_size.to_s,
    }
    @http = HTTPClient.new("#{@base_uri}?#{params}")
    @http.before_request do |request|
      request.headers["Authorization"] ||= auth
      request.headers["Stripe-Version"] ||= "2025-03-31.basil"
      request.headers["User-Agent"] ||= "https://github.com/jgaskins/stripe"
    end
  end

  {% for method in %w[get post patch delete] %}
    def {{method.id}}(path : String, *, params : NamedTuple? = nil, as type : T.class) forall T
      if params
        resource = "#{path}?#{ParamsBuilder.from(params).to_s}"
      else
        resource = path
      end

      response = @http.{{method.id}}(resource)
      if response.success?
        T.from_json(response.body)
      else
        raise RequestError.new(response.body)
      end
    end

    def {{method.id}}(path : String, *, form : NamedTuple, as type : T.class) forall T
      headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded"}
      body = ParamsBuilder.from(form).to_s

      response = @http.{{method.id}}(path, headers: headers, body: body)
      if response.success?
        T.from_json(response.body)
      else
        raise RequestError.new(response.body)
      end
    end
  {% end %}
end
