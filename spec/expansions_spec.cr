require "./spec_helper"
require "http/server"

private record Request, method : String, resource : String, body : String

# Yields a client pointed at a local server and returns the request it made.
# The server always responds with an empty list, so methods that return a
# single resource will fail to deserialize it. That's fine, since we're only
# checking what got sent.
private def request_for(&)
  requests = Channel(Request).new(1)
  server = HTTP::Server.new do |context|
    request = context.request
    requests.send Request.new(request.method, URI.decode(request.resource), URI.decode(request.body.try(&.gets_to_end) || ""))
    context.response.content_type = "application/json"
    context.response << %({"object":"list","url":"/","has_more":false,"data":[]})
  end
  address = server.bind_unused_port
  spawn server.listen

  begin
    yield Stripe::Client.new("sk_test", URI.parse("http://#{address}"))
  rescue JSON::SerializableError
  end

  requests.receive
ensure
  server.try &.close
end

describe "expansions" do
  describe Stripe::Charges do
    it "lists with nested expansions" do
      request = request_for do |stripe|
        stripe.charges.list expand: [
          stripe.charges.expand(:customer, :payment_intent),
          stripe.payment_intents.expand(:latest_charge),
        ]
      end

      request.resource.should eq "/v1/charges?expand[]=data.customer&expand[]=data.payment_intent&expand[]=data.payment_intent.latest_charge"
    end

    it "retrieves" do
      request_for(&.charges.retrieve("ch_123", expand: :customer))
        .resource.should eq "/v1/charges/ch_123?expand[]=customer"
    end

    it "searches" do
      request_for(&.charges.search("amount>999", expand: :customer))
        .resource.should eq "/v1/charges/search?query=amount>999&expand[]=data.customer"
    end

    it "creates" do
      request_for(&.charges.create(amount: 100, currency: :usd, expand: :customer))
        .body.should eq "amount=100&currency=usd&expand[]=customer"
    end

    it "updates" do
      request_for(&.charges.update("ch_123", expand: ["refunds"]))
        .body.should eq "expand[]=refunds"
    end

    it "captures" do
      request_for(&.charges.capture("ch_123", expand: :payment_intent))
        .body.should eq "expand[]=payment_intent"
    end
  end

  describe Stripe::Customers do
    it "lists" do
      request_for(&.customers.list(expand: :subscriptions))
        .resource.should eq "/v1/customers?expand[]=data.subscriptions"
    end

    it "retrieves" do
      request = request_for do |stripe|
        stripe.customers.retrieve "cus_123", expand: stripe.customers.expand(:sources, :test_clock)
      end

      request.resource.should eq "/v1/customers/cus_123?expand[]=sources&expand[]=test_clock"
    end

    it "searches" do
      request_for(&.customers.search({email: "me@example.com"}, expand: :subscriptions))
        .resource.should eq %{/v1/customers/search?query=email:"me@example.com"&expand[]=data.subscriptions}
    end

    it "creates" do
      request_for(&.customers.create(email: "me@example.com", expand: :sources))
        .body.should eq "email=me@example.com&expand[]=sources"
    end

    it "updates" do
      request_for(&.customers.update("cus_123", name: "Me", expand: :sources))
        .body.should eq "name=Me&expand[]=sources"
    end
  end

  describe Stripe::PaymentIntents do
    it "lists with nested expansions" do
      request = request_for do |stripe|
        stripe.payment_intents.list(
          customer: "cus_123",
          created: Time.unix(1_000)...Time.unix(2_000),
          expand: [
            stripe.payment_intents.expand(:customer, :latest_charge),
            stripe.charges.expand(:customer),
          ],
        )
      end

      request.resource.should eq "/v1/payment_intents?customer=cus_123&created[gte]=1000&created[lt]=2000&expand[]=data.customer&expand[]=data.latest_charge&expand[]=data.latest_charge.customer"
    end

    it "creates" do
      request_for(&.payment_intents.create(amount: 1000, currency: :usd, expand: :payment_method))
        .body.should eq "amount=1000&currency=usd&expand[]=payment_method"
    end
  end

  describe Stripe::PaymentMethods do
    it "retrieves with nested expansions" do
      request = request_for do |stripe|
        stripe.payment_methods.retrieve "pm_123", expand: [
          stripe.payment_methods.expand(:customer),
          stripe.customers.expand(:subscriptions),
        ]
      end

      request.resource.should eq "/v1/payment_methods/pm_123?expand[]=customer&expand[]=customer.subscriptions"
    end

    it "creates" do
      request = request_for do |stripe|
        stripe.payment_methods.create(
          type: :card,
          card: Stripe::PaymentMethod::Card.new(number: "4242424242424242", exp_month: 12, exp_year: 2030),
          expand: :customer,
        )
      end

      request.body.should eq "type=card&card[number]=4242424242424242&card[exp_month]=12&card[exp_year]=2030&expand[]=customer"
    end

    it "attaches" do
      request_for(&.payment_methods.attach("pm_123", "cus_123", expand: :customer))
        .body.should eq "customer=cus_123&expand[]=customer"
    end
  end

  describe Stripe::Prices do
    it "lists with nested expansions" do
      request = request_for do |stripe|
        stripe.prices.list expand: [
          stripe.prices.expand(:product),
          stripe.products.expand(:default_price),
        ]
      end

      request.resource.should eq "/v1/prices?expand[]=data.product&expand[]=data.product.default_price"
    end

    it "updates" do
      request_for(&.prices.update("price_123", expand: :tiers))
        .body.should eq "expand[]=tiers"
    end
  end

  describe Stripe::Products do
    it "lists" do
      request_for(&.products.list(expand: :default_price))
        .resource.should eq "/v1/products?expand[]=data.default_price"
    end

    it "creates with nested expansions" do
      request = request_for do |stripe|
        stripe.products.create "Widget", expand: [
          stripe.products.expand(:default_price),
          stripe.prices.expand(:tiers),
        ]
      end

      request.body.should eq "name=Widget&expand[]=default_price&expand[]=default_price.tiers"
    end

    it "updates" do
      request_for(&.products.update("prod_123", expand: :default_price))
        .body.should eq "expand[]=default_price"
    end
  end

  describe Stripe::SetupIntents do
    it "retrieves with nested expansions" do
      request = request_for do |stripe|
        stripe.setup_intents.retrieve "seti_123", expand: [
          stripe.setup_intents.expand(:payment_method),
          stripe.payment_methods.expand(:customer),
        ]
      end

      request.resource.should eq "/v1/setup_intents/seti_123?expand[]=payment_method&expand[]=payment_method.customer"
    end

    it "creates" do
      request = request_for do |stripe|
        stripe.setup_intents.create(
          payment_method_types: [Stripe::PaymentMethod::Type::Card],
          expand: :customer,
        )
      end

      request.body.should eq "payment_method_types[]=card&expand[]=customer"
    end
  end

  describe Stripe::Subscriptions do
    it "lists with nested expansions" do
      request = request_for do |stripe|
        stripe.subscriptions.list customer: "cus_123", expand: [
          stripe.subscriptions.expand(:customer, :pending_setup_intent),
          stripe.setup_intents.expand(:payment_method),
        ]
      end

      request.resource.should eq "/v1/subscriptions?customer=cus_123&expand[]=data.customer&expand[]=data.pending_setup_intent&expand[]=data.pending_setup_intent.payment_method"
    end
  end

  describe Stripe::Checkout::Sessions do
    it "creates with nested expansions" do
      request = request_for do |stripe|
        stripe.checkout.sessions.create(
          success_url: "https://example.com",
          expand: [
            stripe.checkout.sessions.expand(:subscription),
            stripe.subscriptions.expand(:default_payment_method),
          ],
        )
      end

      request.body.should eq "success_url=https://example.com&mode=payment&expand[]=subscription&expand[]=subscription.default_payment_method"
    end

    it "retrieves" do
      request_for(&.checkout.sessions.retrieve("cs_123", expand: :payment_intent))
        .resource.should eq "/v1/checkout/sessions/cs_123?expand[]=payment_intent"
    end
  end
end
