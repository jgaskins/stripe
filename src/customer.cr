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
  getter? delinquent : Bool?
  getter description : String?
  getter discount : JSON::Any
  getter email : String?
  getter invoice_prefix : String?
  getter invoice_settings : InvoiceSettings
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

  define InvoiceSettings do
    getter custom_fields : Array(CustomField)?
    getter default_payment_method : String?
    getter footer : String?
    getter rendering_options : RenderingOptions?

    def initialize(
      *,
      custom_fields = nil,
      @default_payment_method = nil,
      @footer = nil,
      @rendering_options = nil,
    )
      @custom_fields = transform_custom_fields(custom_fields)
    end

    def transform_custom_fields(fields : Array(CustomField)?)
      fields
    end

    def transform_custom_fields(fields : Hash(String, String))
      fields.each_with_object(Array.new(fields.size)) do |key, value, result|
        result << CustomField.new(key, value)
      end
    end

    define CustomField do
      getter name : String
      getter value : String
    end

    define RenderingOptions do
      getter amount_tax_display : String?
      getter template : String?
    end
  end
end
