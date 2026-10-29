require "./api"
require "./list"
require "./price"
require "./currency"
require "./products"

module Stripe
  API.define Prices do
    def list(
      *,
      active : Bool? = nil,
      type : Price::Type? = nil,
      product : Product | String | Nil = nil,
      expand : Expansions? = nil,
    ) : List(Price)
      if product.is_a? Product
        product = product.id
      end

      client.get "/v1/prices",
        params: {
          active:  active,
          type:    type,
          product: product,
          expand:  format_expand("data", expand),
        },
        as: List(Price)
    end

    def create(
      *,
      currency : Currency,
      product : String | Product,
      nickname : String? = nil,
      recurring : Price::Recurring? = nil,
      billing_scheme : Price::BillingScheme,
      tiers_mode : Price::TiersMode? = nil,
      tiers : Array? = nil,
      expand : Expansions? = nil,
      idempotency_key : String? = nil,
    )
      case product
      in String
      in Product
        product = product.id
      end

      tiers = TierConverter.new.call(tiers)

      client.post "/v1/prices",
        form: {
          currency:  to_param(currency),
          product:   product,
          nickname:  nickname,
          recurring: {
            interval:          to_param(recurring.try &.interval),
            interval_count:    recurring.try &.interval_count.to_s,
            aggregate_usage:   to_param(recurring.try &.aggregate_usage),
            trial_period_days: recurring.try &.trial_period_days.try &.to_s,
            meter:             recurring.try &.meter,
            usage_type:        to_param(recurring.@usage_type),
          },
          billing_scheme: to_param(billing_scheme),
          tiers_mode:     to_param(tiers_mode),
          tiers:          tiers.try &.map { |tier|
            {
              up_to:       to_param(tier.up_to),
              flat_amount: tier.flat_amount.try &.to_s,
              unit_amount: tier.unit_amount.try &.to_s,
            }
          },
          expand: format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: Price
    end

    def update(
      price : Price | String,
      *,
      active : Bool? = nil,
      expand : Expansions? = nil,
      idempotency_key : String? = nil,
    ) : Price
      price = price.id if price.is_a? Price

      client.post "/v1/prices/#{price}",
        form: {
          active: active,
          expand: format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: Price
    end

    private struct TierConverter
      def call(tiers : Array(Price::Tier))
        tiers
      end

      def call(tiers : Array)
        tiers.map { |tier| convert tier }
      end

      private def convert(tier : Price::Tier)
        tier
      end

      private def convert(tier : NamedTuple)
        Price::Tier.new(**tier)
      end
    end

    def_expand do
      Product
      Tiers
    end

    alias Expansions = Union(
      Expand,
      Array(Expand | Products::Expand),
      Array(String),
    )

    private def format_expand_item(prefix : String?, expand : Products::Expand)
      expand.to_params format_expand_item(prefix, "product")
    end
  end
end
