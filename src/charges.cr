require "./api"
require "./list"
require "./charge"
require "./customer"
require "./payment_intent"
require "./currency"
require "./shipping"

module Stripe
  API.define Charges do
    def list(
      *,
      customer : String | Customer | Nil = nil,
      payment_intent : String | PaymentIntent | Nil = nil,
      transfer_group : String? = nil,
      created : Range(Time?, Time?)? = nil,
      starting_after : String? = nil,
      ending_before : String? = nil,
      limit : Int? = nil,
    ) : List(Charge)
      customer = customer.id if customer.is_a? Customer
      payment_intent = payment_intent.id if payment_intent.is_a? PaymentIntent
      created = created.try do |range|
        latest = range.end.try(&.to_unix.to_s)
        {
          gte: range.begin.try(&.to_unix.to_s),
          lt:  (latest if range.excludes_end?),
          lte: (latest unless range.excludes_end?),
        }
      end

      client.get "/v1/charges",
        params: {
          customer:       customer,
          payment_intent: payment_intent,
          transfer_group: transfer_group,
          created:        created,
          starting_after: starting_after,
          ending_before:  ending_before,
          limit:          limit.try(&.to_s),
        },
        as: List(Charge)
    end

    def retrieve(id : String) : Charge
      client.get "/v1/charges/#{id}", as: Charge
    end

    # Search charges using Stripe's [search query language](https://docs.stripe.com/search#search-query-language).
    #
    # ```
    # stripe.charges.search %{amount>999 AND metadata["order_id"]:"6735"}
    # ```
    def search(query : String, *, limit : Int? = nil, page : String? = nil) : List(Charge)
      client.get "/v1/charges/search",
        params: {
          query: query,
          limit: limit.try(&.to_s),
          page:  page,
        },
        as: List(Charge)
    end

    # Creates a charge directly. Stripe recommends using `PaymentIntents`
    # instead, which also handle authentication flows such as 3D Secure.
    def create(
      *,
      amount : Int,
      currency : Currency,
      customer : String | Customer | Nil = nil,
      source : String? = nil,
      description : String? = nil,
      metadata = nil,
      receipt_email : String? = nil,
      shipping : Shipping? = nil,
      statement_descriptor : String? = nil,
      statement_descriptor_suffix : String? = nil,
      capture : Bool? = nil,
      application_fee_amount : Int? = nil,
      on_behalf_of : String? = nil,
      transfer_data : Charge::TransferData? = nil,
      transfer_group : String? = nil,
      idempotency_key : String? = nil,
    ) : Charge
      customer = customer.id if customer.is_a? Customer

      client.post "/v1/charges",
        form: {
          amount:                      amount.to_s,
          currency:                    currency,
          customer:                    customer,
          source:                      source,
          description:                 description,
          metadata:                    metadata,
          receipt_email:               receipt_email,
          shipping:                    shipping.try(&.to_named_tuple),
          statement_descriptor:        statement_descriptor,
          statement_descriptor_suffix: statement_descriptor_suffix,
          capture:                     capture,
          application_fee_amount:      application_fee_amount.try(&.to_s),
          on_behalf_of:                on_behalf_of,
          transfer_data:               transfer_data.try { |data|
            {
              destination: data.destination,
              amount:      data.amount.try(&.to_s),
            }
          },
          transfer_group: transfer_group,
        },
        idempotency_key: idempotency_key,
        as: Charge
    end

    def update(
      charge : String | Charge,
      *,
      customer : String | Customer | Nil = nil,
      description : String? = nil,
      metadata = nil,
      receipt_email : String? = nil,
      shipping : Shipping? = nil,
      fraud_details : Charge::FraudDetails::Report? = nil,
      transfer_group : String? = nil,
      idempotency_key : String? = nil,
    ) : Charge
      charge = charge.id if charge.is_a? Charge
      customer = customer.id if customer.is_a? Customer

      client.post "/v1/charges/#{charge}",
        form: {
          customer:       customer,
          description:    description,
          metadata:       metadata,
          receipt_email:  receipt_email,
          shipping:       shipping.try(&.to_named_tuple),
          fraud_details:  fraud_details.try { |report| {user_report: report} },
          transfer_group: transfer_group,
        },
        idempotency_key: idempotency_key,
        as: Charge
    end

    # Captures a charge created with `capture: false`. Captures the full
    # authorized amount unless `amount` is given.
    def capture(
      charge : String | Charge,
      *,
      amount : Int? = nil,
      application_fee_amount : Int? = nil,
      receipt_email : String? = nil,
      statement_descriptor : String? = nil,
      statement_descriptor_suffix : String? = nil,
      transfer_amount : Int? = nil,
      transfer_group : String? = nil,
      idempotency_key : String? = nil,
    ) : Charge
      charge = charge.id if charge.is_a? Charge

      client.post "/v1/charges/#{charge}/capture",
        form: {
          amount:                      amount.try(&.to_s),
          application_fee_amount:      application_fee_amount.try(&.to_s),
          receipt_email:               receipt_email,
          statement_descriptor:        statement_descriptor,
          statement_descriptor_suffix: statement_descriptor_suffix,
          transfer_data:               {amount: transfer_amount.try(&.to_s)},
          transfer_group:              transfer_group,
        },
        idempotency_key: idempotency_key,
        as: Charge
    end

    def_expand do
      Customer
      PaymentIntent
      # BalanceTransaction
      # Application
      # ApplicationFee
      # FailureBalanceTransaction
      # OnBehalfOf
      # Refunds
      # Review
      # SourceTransfer
      # Transfer
    end
  end
end
