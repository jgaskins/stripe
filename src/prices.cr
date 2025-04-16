require "./api"
require "./list"
require "./price"
require "./currency"

module Stripe
  API.define Prices do
    def list(
      *,
      active : Bool? = nil,
      type : Price::Type? = nil,
      product : Product | String | Nil = nil,
      expand : Expand? = nil
    ) : List(Price)
      if product.is_a? Product
        product = product.id
      end
      if expand
        expand = expand.members.map(&.to_param(:data))
      end

      client.get "/v1/prices",
        params: {
          active:  active,
          type:    type,
          product: product,
          expand:  expand,
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
        },
        as: Price
    end

    def update(
      price : Price | String,
      *,
      active : Bool? = nil,
    ) : Price
      price = price.id if price.is_a? Price

      client.post "/v1/prices/#{price}",
        form: {
          active: active,
        },
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

    @[Flags]
    enum Expand
      Product
      Tiers

      def to_param(prefix) : String
        if prefix
          "#{prefix}.#{to_s}"
        else
          to_s
        end
      end

      def members
        members = [] of self
        each do |member|
          members << member
        end
        members
      end

      def to_s
        case self
        when .product?
          "product"
        when .tiers?
          "tiers"
        else
          raise "BUG: THIS SHOULD NEVER HAPPEN"
        end
      end
    end
  end
end
