require "./api"

require "./payment_method"
require "./customer"

module Stripe
  API.define SetupIntents do
    def retrieve(id : String) : SetupIntent
      client.get "/v1/setup_intents/#{id}", as: SetupIntent
    end

    def create(
      *,
      customer : String? = nil,
      description : String? = nil,
      confirm : Bool? = nil,
      payment_method : String? = nil,
      usage : SetupIntent::Usage? = nil,
      payment_method_types : Array(PaymentMethod::Type),
      idempotency_key : String? = nil,
    ) : SetupIntent
      client.post "/v1/setup_intents",
        form: {
          customer:             customer,
          description:          description,
          confirm:              confirm,
          payment_method:       payment_method,
          payment_method_types: payment_method_types.map { |type| to_param(type) },
        },
        idempotency_key: idempotency_key,
        as: SetupIntent
    end
  end
end
