require "./api"
require "./refund"
require "./time_range"
require "./charges"
require "./payment_intents"

module Stripe
  API.define Refunds do
    def list(
      *,
      charge : String? = nil,
      payment_intent : String? = nil,
      created : TimeRange? = nil,
      limit : Int? = nil,
      starting_after : String? = nil,
      ending_before : String? = nil,
      expand : Expansions? = nil,
    )
      client.get "/v1/refunds",
        params: {
          charge:         charge,
          payment_intent: payment_intent,
          created:        created,
          limit:          limit.try(&.to_s),
          starting_after: starting_after,
          ending_before:  ending_before,
          expand:         format_expand("data", expand),
        },
        as: List(Refund)
    end

    def retrieve(id : String, *, expand : Expansions? = nil) : Refund
      client.get "/v1/refunds/#{id}",
        params: {expand: format_expand(nil, expand)},
        as: Refund
    end

    # Refunds the full amount of the payment intent unless `amount` is given
    def create(
      payment_intent : String,
      amount : Int? = nil,
      metadata = nil,
      expand : Expansions? = nil,
    ) : Refund
      client.post "/v1/refunds",
        form: {
          payment_intent: payment_intent,
          amount:         amount.try(&.to_s),
          metadata:       metadata,
          expand:         format_expand(nil, expand),
        },
        as: Refund
    end

    def_expand do
      Charge
      PaymentIntent
    end

    alias Expansions = Union(
      Expand,
      Array(Expand | Charges::Expand | PaymentIntents::Expand),
      Array(String),
    )

    private def format_expand_item(prefix : String?, expand : Charges::Expand)
      expand.to_params format_expand_item(prefix, "charge")
    end

    private def format_expand_item(prefix : String?, expand : PaymentIntents::Expand)
      expand.to_params format_expand_item(prefix, "payment_intent")
    end
  end
end
