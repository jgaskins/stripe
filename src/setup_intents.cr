require "./api"

require "./payment_method"
require "./customer"
require "./customers"
require "./payment_methods"

module Stripe
  API.define SetupIntents do
    def retrieve(id : String, *, expand : Expansions? = nil) : SetupIntent
      client.get "/v1/setup_intents/#{id}",
        params: {expand: format_expand(nil, expand)},
        as: SetupIntent
    end

    def create(
      *,
      customer : String? = nil,
      description : String? = nil,
      confirm : Bool? = nil,
      payment_method : String? = nil,
      usage : SetupIntent::Usage? = nil,
      payment_method_types : Array(PaymentMethod::Type),
      expand : Expansions? = nil,
      idempotency_key : String? = nil,
    ) : SetupIntent
      client.post "/v1/setup_intents",
        form: {
          customer:             customer,
          description:          description,
          confirm:              confirm,
          payment_method:       payment_method,
          payment_method_types: payment_method_types.map { |type| to_param(type) },
          expand:               format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: SetupIntent
    end

    def_expand do
      Customer
      PaymentMethod
    end

    alias Expansions = Union(
      Expand,
      Array(Expand | Customers::Expand | PaymentMethods::Expand),
      Array(String),
    )

    private def format_expand_item(prefix : String?, expand : Customers::Expand)
      expand.to_params format_expand_item(prefix, "customer")
    end

    private def format_expand_item(prefix : String?, expand : PaymentMethods::Expand)
      expand.to_params format_expand_item(prefix, "payment_method")
    end
  end
end
