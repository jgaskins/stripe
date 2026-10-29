require "uri/params"
require "../api"
require "../list"
require "../line_item"
require "../customers"
require "../payment_intents"
require "../setup_intents"
require "../subscriptions"

module Stripe
  API.define Checkout do
    def sessions
      Sessions.new client
    end

    struct Sessions < API
      def create(
        *,
        customer : String? = nil,
        success_url : URI | String | Nil = nil,
        cancel_url : URI | String | Nil = nil,
        mode : Session::Mode = :payment,
        line_items : Array(LineItem)? = nil,
        expand : Expansions? = nil,
        idempotency_key : String? = nil,
      )
        client.post "/v1/checkout/sessions",
          form: {
            customer:    customer,
            success_url: success_url,
            cancel_url:  cancel_url,
            mode:        mode,
            line_items:  line_items.try &.map do |line_item|
              {
                price:    line_item.price.to_s,
                quantity: line_item.quantity.to_s,
              }
            end,
            expand: format_expand(nil, expand),
          },
          idempotency_key: idempotency_key,
          as: Session
      end

      def retrieve(id : String, *, expand : Expansions? = nil) : Session?
        client.get "/v1/checkout/sessions/#{id}",
          params: {expand: format_expand(nil, expand)},
          as: Session
      end

      def_expand do
        Customer
        PaymentIntent
        SetupIntent
        Subscription
      end

      alias Expansions = Union(
        Expand,
        Array(Expand | Customers::Expand | PaymentIntents::Expand | SetupIntents::Expand | Subscriptions::Expand),
        Array(String),
      )

      private def format_expand_item(prefix : String?, expand : Customers::Expand)
        expand.to_params format_expand_item(prefix, "customer")
      end

      private def format_expand_item(prefix : String?, expand : PaymentIntents::Expand)
        expand.to_params format_expand_item(prefix, "payment_intent")
      end

      private def format_expand_item(prefix : String?, expand : SetupIntents::Expand)
        expand.to_params format_expand_item(prefix, "setup_intent")
      end

      private def format_expand_item(prefix : String?, expand : Subscriptions::Expand)
        expand.to_params format_expand_item(prefix, "subscription")
      end
    end
  end
end

require "./session"
