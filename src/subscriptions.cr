require "./api"
require "./list"
require "./payment_intent"
require "./customer"

module Stripe
  API.define Subscriptions do
    def list(
      customer : Customer | String | Nil = nil,
      status : Subscription::Status? = nil,
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
        },
        as: List(Subscription)
    end
  end
end
