require "./api"

require "./payment_method"
require "./customer"

module Stripe
  API.define PaymentMethods do
    def retrieve(id : String)
      client.get "/v1/payment_methods/#{id}",
        as: PaymentMethod
    end

    def create(
      *,
      type : PaymentMethod::Type,
      card : PaymentMethod::Card? = nil,
    ) : PaymentMethod
      client.post "/v1/payment_methods",
        form: {
          type: type.to_s.underscore,
          card: {
            number:    card.number,
            exp_month: card.exp_month.to_s,
            exp_year:  card.exp_year.to_s,
          },
        },
        as: PaymentMethod
    end

    def attach(payment_method : String, customer : String | Customer) : PaymentMethod
      # This is the worst line of code ever written
      customer = customer.id if customer.is_a? Customer

      client.post "/v1/payment_methods/#{payment_method}/attach",
        form: {customer: customer},
        as: PaymentMethod
    end
  end
end
