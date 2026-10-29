require "./api"
require "./list"
require "./payment_intent"
require "./customer"
require "./time_range"
require "./customers"
require "./charges"
require "./payment_methods"

module Stripe
  API.define PaymentIntents do
    def list(
      customer : String | Customer | Nil = nil,
      created : Range(Time?, Time?)? = nil,
      starting_after : String? = nil,
      ending_before : String? = nil,
      limit : Int? = nil,
      expand : Expansions? = nil,
    ) : List(PaymentIntent)
      customer = customer.id if customer.is_a? Customer

      client.get "/v1/payment_intents",
        params: {
          customer:       customer,
          created:        created.try { |range| TimeRange.new(range) },
          starting_after: starting_after,
          ending_before:  ending_before,
          limit:          limit.try(&.to_s),
          expand:         format_expand("data", expand),
        },
        as: List(PaymentIntent)
    end

    def create(
      amount : Int,
      currency : Currency,
      customer : String? = nil,
      confirm : Bool? = nil,
      payment_method : String? = nil,
      automatic_payment_methods : AutomaticPaymentMethods? = nil,
      metadata = nil,
      idempotency_key : String? = nil,
      expand : Expansions? = nil,
    ) : PaymentIntent
      client.post "/v1/payment_intents",
        form: {
          amount:                    amount.to_s,
          currency:                  currency,
          customer:                  customer,
          confirm:                   confirm,
          payment_method:            payment_method,
          automatic_payment_methods: automatic_payment_methods.try(&.to_named_tuple),
          metadata:                  metadata,
          expand:                    format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: PaymentIntent
    end

    def_expand do
      Customer
      LatestCharge
      PaymentMethod
      Review
    end

    alias Expansions = Union(
      Expand,
      Array(Expand | Customers::Expand | Charges::Expand | PaymentMethods::Expand),
      Array(String),
    )

    private def format_expand_item(prefix : String?, expand : Customers::Expand)
      expand.to_params format_expand_item(prefix, "customer")
    end

    private def format_expand_item(prefix : String?, expand : Charges::Expand)
      expand.to_params format_expand_item(prefix, "latest_charge")
    end

    private def format_expand_item(prefix : String?, expand : PaymentMethods::Expand)
      expand.to_params format_expand_item(prefix, "payment_method")
    end
  end
end
