require "./resource"
require "./currency"
require "./payment_method"

struct Stripe::Price
  include Resource
  include JSON::Serializable::Unmapped

  getter id : String
  getter? active : Bool
  getter currency : Currency
  getter metadata : Metadata
  getter nickname : String?
  getter product : String | Product
  getter recurring : Recurring
  getter type : Type
  getter unit_amount : Int64?
  getter object : String
  getter billing_scheme : BillingScheme
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter currency_options : Hash(String, CurrencyOptions)?
  getter custom_unit_amount : CustomUnitAmount?
  getter? livemode : Bool = false
  getter lookup_key : String?
  getter tax_behavior : TaxBehavior
  getter tiers : Array(Tier)?
  getter tiers_mode : TiersMode?
  getter transform_quantity : TransformQuantity?
  getter unit_amount_decimal : String?

  struct TransformQuantity
    include Resource

    getter divide_by : Int64
    getter round : Round

    enum Round
      Up
      Down
    end
  end

  enum TiersMode
    Graduated
    Volume
  end

  struct CurrencyOptions
    include Resource

    getter custom_unit_amount : CustomUnitAmount
    getter tax_behavior : TaxBehavior?
    getter tiers : Array(Tier)
  end

  enum BillingScheme
    PerUnit
    Tiered
  end

  enum Type
    OneTime
    Recurring
  end

  struct Recurring
    include Resource

    getter aggregate_usage : AggregateUsage?
    getter interval : Interval
    getter interval_count : Int64
    getter trial_period_days : Int64?
    getter meter : String?
    getter! usage_type : UsageType

    def initialize(
      *,
      @interval,
      @interval_count = 1,
      @aggregate_usage = nil,
      @trial_period_days = nil,
      @meter = nil,
      @usage_type = nil,
    )
    end
  end

  enum AggregateUsage
    LastDuringPeriod
    LastEver
    Max
    Sum
  end

  enum Interval
    Day
    Week
    Month
    Year
  end

  enum UsageType
    Metered
    Licensed
  end

  struct CustomUnitAmount
    include Resource
    getter maximum : Int64?
    getter minimum : Int64?
    getter preset : Int64?
  end

  enum TaxBehavior
    Exclusive
    Inclusive
    Unspecified
  end

  struct Tier
    include Resource

    getter flat_amount : Int64?
    getter flat_amount_decimal : String?
    getter unit_amount : Int64?
    getter unit_amount_decimal : String?
    getter up_to : Int64 | Infinity?

    def initialize(@up_to = nil, @flat_amount = nil, @unit_amount = nil)
    end

    enum Infinity
      Inf
    end
  end
end
