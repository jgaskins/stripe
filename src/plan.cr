require "./resource"
require "./currency"

struct Stripe::Plan
  include Resource
  getter id : String
  getter? active : Bool
  getter amount : Int64?
  getter currency : Currency
  getter interval : Interval
  getter metadata : Metadata = Metadata.new
  getter nickname : String?
  getter product : String?
  getter aggregate_usage : AggregateUsage?

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
end
