require "./resource"
require "./currency"
require "./metadata"
require "./address"
require "./tax_exemption"

struct Stripe::Customer
  include Resource

  getter id : String
  getter address : Address?
  getter balance : Int64
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter currency : Currency?
  getter default_source : String?
  getter? delinquent  : Bool?
  getter description : String?
  getter discount : JSON::Any
  getter email : String?
  getter invoice_prefix : String?
  getter invoice_settings : JSON::Any
  getter? livemode : Bool
  getter metadata : Metadata
  getter name : String?
  getter next_invoice_sequence : Int64?
  getter phone : String?
  getter preferred_locales : Array(String)?
  getter shipping : Address?
  getter sources : JSON::Any?
  getter tax_exempt : TaxExemption?
  getter test_clock : JSON::Any
end
