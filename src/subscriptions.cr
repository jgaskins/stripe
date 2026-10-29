require "./api"
require "./list"
require "./payment_intent"
require "./customer"
require "./customers"
require "./payment_methods"
require "./setup_intents"

module Stripe
  API.define Subscriptions do
    def list(
      customer : Customer | String | Nil = nil,
      status : Subscription::Status? = nil,
      expand : Expansions? = nil,
    ) : List(Subscription)
      customer = customer.id if customer.is_a? Customer
      params = ParamsBuilder.from({
        customer: customer,
        status:   status,
      })
      client.get "/v1/subscriptions",
        params: {
          customer: customer,
          status:   status,
          expand:   format_expand("data", expand),
        },
        as: List(Subscription)
    end

    def_expand do
      Customer
      DefaultPaymentMethod
      PendingSetupIntent
    end

    alias Expansions = Union(
      Expand,
      Array(Expand | Customers::Expand | PaymentMethods::Expand | SetupIntents::Expand),
      Array(String),
    )

    private def format_expand_item(prefix : String?, expand : Customers::Expand)
      expand.to_params format_expand_item(prefix, "customer")
    end

    private def format_expand_item(prefix : String?, expand : PaymentMethods::Expand)
      expand.to_params format_expand_item(prefix, "default_payment_method")
    end

    private def format_expand_item(prefix : String?, expand : SetupIntents::Expand)
      expand.to_params format_expand_item(prefix, "pending_setup_intent")
    end
  end
end
