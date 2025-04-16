require "uri/params"
require "../api"
require "../list"
require "../line_item"

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
          },
          as: Session
      end

      def retrieve(id : String) : Session?
        client.get "/v1/checkout/sessions/#{id}", as: Session
      end
    end
  end
end

require "./session"
