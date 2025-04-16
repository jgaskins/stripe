require "./api"
require "./list"
require "./payment_intent"
require "./customer"

module Stripe
  API.define PaymentIntents do
    def list(
      customer : String | Customer | Nil = nil,
      created : Range(Time?, Time?)? = nil,
      starting_after : String? = nil,
      ending_before : String? = nil,
      limit : Int? = nil,
      expand : Expand? = nil,
    ) : List(PaymentIntent)
      params = URI::Params.new
      case customer
      in Nil
      in Customer
        params["customer"] = customer.id
      in String
        params["customer"] = customer
      end
      if created
        if earliest = created.begin
          params["customer.gte"] = earliest.to_unix.to_s
        end
        if latest = created.end
          params["customer.lt#{'e' if created.exclusive_end?}"] = latest.to_unix.to_s
        end
      end
      params["starting_after"] = starting_after if starting_after
      params["ending_before"] = ending_before if ending_before
      params["limit"] = limit.to_s if limit
      expand.try &.each do |value|
        params.add "expand[]", value.to_param(:data)
      end

      client.get "/v1/payment_intents?#{params}", as: List(PaymentIntent)
    end

    @[Flags]
    enum Expand
      PaymentMethod
      PaymentMethodCustomer

      def to_param(prefix) : String
        if prefix
          "#{prefix}.#{to_s}"
        else
          to_s
        end
      end

      def to_s
        case self
        when .payment_method?
          "payment_method"
        when .payment_method_customer?
          "payment_method.customer"
        else
          raise "BUG: THIS SHOULD NEVER HAPPEN"
        end
      end
    end
  end
end
