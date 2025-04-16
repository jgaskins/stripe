require "./api"

require "./payment_method"
require "./customer"

module Stripe
  API.define SetupIntents do
    def create(
      *,
      customer : String? = nil,
      description : String? = nil,
      confirm : Bool? = nil,
      payment_method : String? = nil,
      usage : SetupIntent::Usage? = nil,
      payment_method_types : Array(PaymentMethod::Type),
    ) : SetupIntent
      client.post "/v1/setup_intents",
        form: {
          customer:             customer,
          description:          description,
          confirm:              confirm,
          payment_method:       payment_method,
          payment_method_types: payment_method_types.map { |type| to_param(type) },
        },
        as: SetupIntent
    end
  end
end
