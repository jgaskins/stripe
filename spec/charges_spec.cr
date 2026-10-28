require "./spec_helper"
require "http/server"

private CHARGE_JSON = <<-JSON
  {
    "id": "ch_3MmlLrLkdIwHu7ix0snN0B15",
    "object": "charge",
    "amount": 1099,
    "amount_captured": 1099,
    "amount_refunded": 0,
    "application": null,
    "application_fee": null,
    "application_fee_amount": null,
    "balance_transaction": "txn_3MmlLrLkdIwHu7ix0uke3Ezy",
    "billing_details": {
      "address": {
        "city": null,
        "country": null,
        "line1": null,
        "line2": null,
        "postal_code": null,
        "state": null
      },
      "email": null,
      "name": null,
      "phone": null,
      "tax_id": null
    },
    "calculated_statement_descriptor": "Stripe",
    "captured": true,
    "created": 1679090539,
    "currency": "usd",
    "customer": null,
    "description": null,
    "disputed": false,
    "failure_balance_transaction": null,
    "failure_code": null,
    "failure_message": null,
    "fraud_details": {},
    "livemode": false,
    "metadata": {},
    "on_behalf_of": null,
    "outcome": {
      "network_status": "approved_by_network",
      "reason": null,
      "risk_level": "normal",
      "risk_score": 32,
      "seller_message": "Payment complete.",
      "type": "authorized"
    },
    "paid": true,
    "payment_intent": null,
    "payment_method": "card_1MmlLrLkdIwHu7ixIJwEWSNR",
    "payment_method_details": {
      "card": {
        "amount_authorized": 1099,
        "brand": "visa",
        "checks": {
          "address_line1_check": null,
          "address_postal_code_check": null,
          "cvc_check": null
        },
        "country": "US",
        "exp_month": 3,
        "exp_year": 2024,
        "fingerprint": "mToisGZ01V71BCos",
        "funding": "credit",
        "installments": null,
        "last4": "4242",
        "mandate": null,
        "network": "visa",
        "three_d_secure": null,
        "wallet": null
      },
      "type": "card"
    },
    "receipt_email": null,
    "receipt_number": null,
    "receipt_url": "https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTTJKVGtMa2RJd0h1N2l4KOvG06AGMgZfBXyr1aw6LBa9vaaSRWU96d8qBwz9z2J_CObiV_H2-e8RezSK_sw0KISesp4czsOUlVKY",
    "refunded": false,
    "review": null,
    "shipping": null,
    "source_transfer": null,
    "statement_descriptor": null,
    "statement_descriptor_suffix": null,
    "status": "succeeded",
    "transfer_data": null,
    "transfer_group": null
  }
  JSON

private record Request, method : String, resource : String, body : String

private def with_server(response_body = CHARGE_JSON, &)
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

describe Stripe::Charge do
  it "deserializes from JSON" do
    charge = Stripe::Charge.from_json(CHARGE_JSON)

    charge.id.should eq "ch_3MmlLrLkdIwHu7ix0snN0B15"
    charge.amount.should eq 1099
    charge.currency.should eq Stripe::Currency::USD
    charge.status.succeeded?.should be_true
    charge.created.should eq Time.unix(1679090539)
    charge.captured?.should be_true
    charge.fraud_details.should eq Stripe::Charge::FraudDetails.new(stripe_report: nil, user_report: nil)

    details = charge.payment_method_details.should_not be_nil
    details.type.card?.should be_true
    card = details.card.should_not be_nil
    card.brand.should eq Stripe::PaymentMethod::Card::Brand::Visa
    card.funding.should eq Stripe::PaymentMethod::Card::Funding::Credit
    card.last4.should eq "4242"
  end
end

describe Stripe::Charges do
  it "lists charges" do
    with_server %({"object":"list","url":"/v1/charges","has_more":false,"data":[#{CHARGE_JSON}]}) do |stripe, requests|
      charges = stripe.charges.list(
        customer: "cus_123",
        created: Time.unix(1_000)...Time.unix(2_000),
        limit: 3,
      )

      charges.first.id.should eq "ch_3MmlLrLkdIwHu7ix0snN0B15"
      request = requests.receive
      request.method.should eq "GET"
      URI.decode(request.resource).should eq "/v1/charges?customer=cus_123&created[gte]=1000&created[lt]=2000&limit=3"
    end
  end

  it "searches charges" do
    with_server %({"object":"search_result","url":"/v1/charges/search","has_more":false,"data":[]}) do |stripe, requests|
      stripe.charges.search %{metadata["order_id"]:"6735"}

      URI.decode(requests.receive.resource).should eq %{/v1/charges/search?query=metadata["order_id"]:"6735"}
    end
  end

  it "retrieves a charge" do
    with_server do |stripe, requests|
      stripe.charges.retrieve("ch_123")

      requests.receive.resource.should eq "/v1/charges/ch_123"
    end
  end

  it "creates a charge" do
    with_server do |stripe, requests|
      stripe.charges.create(
        amount: 1099,
        currency: :usd,
        source: "tok_visa",
        capture: false,
        transfer_data: Stripe::Charge::TransferData.new(destination: "acct_123"),
        idempotency_key: "key",
      )

      request = requests.receive
      request.method.should eq "POST"
      request.resource.should eq "/v1/charges"
      URI.decode(request.body).should eq "amount=1099&currency=usd&source=tok_visa&capture=false&transfer_data[destination]=acct_123"
    end
  end

  it "updates a charge" do
    with_server do |stripe, requests|
      stripe.charges.update "ch_123",
        description: "Updated",
        fraud_details: :fraudulent

      request = requests.receive
      request.resource.should eq "/v1/charges/ch_123"
      URI.decode(request.body).should eq "description=Updated&fraud_details[user_report]=fraudulent"
    end
  end

  it "captures a charge" do
    with_server do |stripe, requests|
      stripe.charges.capture "ch_123", amount: 500

      request = requests.receive
      request.resource.should eq "/v1/charges/ch_123/capture"
      request.body.should eq "amount=500"
    end
  end
end
