require "./resource"
require "./metadata"

struct Stripe::Product
  include Resource

  getter id : String
  getter? active : Bool
  getter default_price : String?
  getter description : String?
  getter metadata : Metadata
  getter name : String
  getter object : String
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter images : Array(String)
  getter? livemode : Bool = false
  getter marketing_features : Array(MarketingFeature)
  getter package_dimensions : PackageDimensions?
  getter? shippable : Bool?
  getter statement_descriptor : String?
  getter tax_code : String?
  getter unit_label : String?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter updated : Time
  getter url : String?

  struct PackageDimensions
    include Resource

    getter height : Float64
    getter length : Float64
    getter weight : Float64
    getter width : Float64
  end

  struct MarketingFeature
    include Resource

    getter name : String?
  end
end
