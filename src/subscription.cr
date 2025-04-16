require "./resource"
require "./currency"
require "./list"
require "./plan"
require "./price"

struct Stripe::Subscription
  include Resource

  getter id : String
  getter? cancel_at_period_end : Bool
  getter currency : Currency
  @[JSON::Field(converter: Time::EpochConverter)]
  getter current_period_end : Time
  @[JSON::Field(converter: Time::EpochConverter)]
  getter current_period_start : Time
  getter customer : String
  getter default_payment_method : String?
  getter description : String?
  getter items : List(Item)
  getter plan : Plan?
  getter latest_invoice : String?
  getter metadata : Metadata
  getter pending_setup_intent : String?
  getter pending_update : JSON::Any
  getter status : Status
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  @[JSON::Field(converter: Time::EpochConverter)]
  getter ended_at : Time?
  getter collection_method : CollectionMethod
  getter days_until_due : Int64?
  getter default_source : String?
  getter discounts : Array(String)?
  getter? livemode : Bool
  getter on_behalf_of : String?
  getter pause_collection : JSON::Any
  getter payment_settings : JSON::Any
  @[JSON::Field(converter: Time::EpochConverter)]
  getter start_date : Time
  getter schedule : String?

  enum CollectionMethod
    ChargeAutomatically
    SendInvoice
  end

  enum Status
    Incomplete
    IncompleteExpired
    Trialing
    Active
    PastDue
    Canceled
    Unpaid
    Paused
  end

  struct Item
    include Resource

    getter id : String
    getter object : String
    getter billing_thresholds : JSON::Any
    @[JSON::Field(converter: Time::EpochConverter)]
    getter created : Time
    getter discounts : Array(String)
    getter metadata : Metadata
    getter plan : Plan
    getter price : Price
    getter quantity : Int64?
    getter subscription : String
    getter tax_rates : Array(JSON::Any)?
  end
end
