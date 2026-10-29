require "./api"

require "./payment_method"
require "./customer"
require "./customers"

module Stripe
  API.define PaymentMethods do
    def retrieve(id : String, *, expand : Expansions? = nil)
      client.get "/v1/payment_methods/#{id}",
        params: {expand: format_expand(nil, expand)},
        as: PaymentMethod
    end

    def create(
      *,
      type : PaymentMethod::Type,
      card : PaymentMethod::Card? = nil,
      expand : Expansions? = nil,
      idempotency_key : String? = nil,
    ) : PaymentMethod
      client.post "/v1/payment_methods",
        form: {
          type: type.to_s.underscore,
          card: {
            number:    card.number,
            exp_month: card.exp_month.to_s,
            exp_year:  card.exp_year.to_s,
          },
          expand: format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: PaymentMethod
    end

    def attach(
      payment_method : String,
      customer : String | Customer,
      idempotency_key : String? = nil,
      expand : Expansions? = nil,
    ) : PaymentMethod
      # This is the worst line of code ever written
      customer = customer.id if customer.is_a? Customer

      client.post "/v1/payment_methods/#{payment_method}/attach",
        form: {
          customer: customer,
          expand:   format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: PaymentMethod
    end

    def_expand do
      Customer
    end

    alias Expansions = Union(
      Expand,
      Array(Expand | Customers::Expand),
      Array(String),
    )

    private def format_expand_item(prefix : String?, expand : Customers::Expand)
      expand.to_params format_expand_item(prefix, "customer")
    end
  end
end
