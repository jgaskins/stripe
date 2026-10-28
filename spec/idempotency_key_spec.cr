require "./spec_helper"
require "http/server"

private def with_server(&)
  requests = Channel(HTTP::Request).new(1)
  server = HTTP::Server.new do |context|
    requests.send context.request
    context.response.content_type = "application/json"
    context.response << %({"id":"prod_123"})
  end
  address = server.bind_unused_port
  spawn server.listen

  begin
    yield Stripe::Client.new("sk_test", URI.parse("http://#{address}")), requests
  ensure
    server.close
  end
end

private struct IDResponse
  include JSON::Serializable

  getter id : String
end

describe Stripe::Client do
  it "sends the Idempotency-Key header on POST requests" do
    with_server do |stripe, requests|
      stripe.post "/v1/products",
        form: {name: "Foo"},
        idempotency_key: "my-key",
        as: IDResponse

      requests.receive.headers["Idempotency-Key"].should eq "my-key"
    end
  end

  it "omits the Idempotency-Key header when no key is given" do
    with_server do |stripe, requests|
      stripe.post "/v1/products",
        form: {name: "Foo"},
        as: IDResponse

      requests.receive.headers.has_key?("Idempotency-Key").should be_false
    end
  end
end
