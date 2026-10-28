require "./spec_helper"
require "http/server"

private REFUND_JSON = <<-JSON
  {
    "id": "re_123",
    "object": "refund",
    "amount": 1000,
    "charge": "ch_123",
    "created": 1692942318,
    "currency": "usd",
    "metadata": {},
    "payment_intent": "pi_123",
    "reason": null,
    "status": "succeeded"
  }
  JSON

private CHARGE_JSON = <<-JSON
  {
    "id": "ch_123",
    "object": "charge",
    "amount": 1000,
    "amount_captured": 1000,
    "amount_refunded": 1000,
    "billing_details": {"address": null, "email": null, "name": null, "phone": null, "tax_id": null},
    "captured": true,
    "created": 1692942318,
    "currency": "usd",
    "disputed": false,
    "livemode": false,
    "metadata": {},
    "paid": true,
    "payment_intent": "pi_123",
    "refunded": true,
    "status": "succeeded"
  }
  JSON

private PAYMENT_INTENT_JSON = <<-JSON
  {
    "id": "pi_123",
    "object": "payment_intent",
    "amount": 1000,
    "amount_capturable": 0,
    "amount_received": 1000,
    "created": 1692942318,
    "currency": "usd",
    "latest_charge": "ch_123",
    "livemode": false,
    "metadata": {},
    "status": "succeeded"
  }
  JSON

private record Request, method : String, resource : String, body : String

private def with_server(response_body = REFUND_JSON, &)
  requests = Channel(Request).new(1)
  server = HTTP::Server.new do |context|
    request = context.request
    requests.send Request.new(request.method, request.resource, request.body.try(&.gets_to_end) || "")
    context.response.content_type = "application/json"
    context.response << response_body
  end
  address = server.bind_unused_port
  spawn server.listen

  begin
    yield Stripe::Client.new("sk_test", URI.parse("http://#{address}")), requests
  ensure
    server.close
  end
end

describe Stripe::Refund do
  it "deserializes unexpanded charge and payment_intent as IDs" do
    refund = Stripe::Refund.from_json(REFUND_JSON)

    refund.charge.should eq "ch_123"
    refund.payment_intent.should eq "pi_123"
  end

  it "deserializes expanded charge and payment_intent" do
    json = REFUND_JSON
      .sub(%("payment_intent": "pi_123"), %("payment_intent": #{PAYMENT_INTENT_JSON}))
      .sub(%("charge": "ch_123"), %("charge": #{CHARGE_JSON}))

    refund = Stripe::Refund.from_json(json)

    refund.charge.as(Stripe::Charge).id.should eq "ch_123"
    refund.payment_intent.as(Stripe::PaymentIntent).id.should eq "pi_123"
  end
end

describe Stripe::Refunds do
  it "lists refunds with expansions" do
    with_server %({"object":"list","url":"/v1/refunds","has_more":false,"data":[]}) do |stripe, requests|
      stripe.refunds.list expand: :all

      URI.decode(requests.receive.resource).should eq "/v1/refunds?expand[]=data.charge&expand[]=data.payment_intent"
    end
  end

  it "retrieves a refund with expansions" do
    with_server do |stripe, requests|
      stripe.refunds.retrieve "re_123", expand: :charge

      URI.decode(requests.receive.resource).should eq "/v1/refunds/re_123?expand[]=charge"
    end
  end

  it "creates a partial refund" do
    with_server do |stripe, requests|
      stripe.refunds.create "pi_123", amount: 500

      requests.receive.body.should eq "payment_intent=pi_123&amount=500"
    end
  end

  it "creates a refund with expansions" do
    with_server do |stripe, requests|
      stripe.refunds.create "pi_123", expand: :payment_intent

      URI.decode(requests.receive.body).should eq "payment_intent=pi_123&expand[]=payment_intent"
    end
  end
end
