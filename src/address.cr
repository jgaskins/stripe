require "./resource"

struct Stripe::Address
  include JSON::Serializable

  # City, district, suburb, town, or village.
  getter city : String?

  # Two-letter country code (ISO 3166-1 alpha-2).
  getter country : String?

  # Address line 1 (e.g., street, PO Box, or company name).
  getter line1 : String?

  # Address line 2 (e.g., apartment, suite, unit, or building).
  getter line2 : String?

  # ZIP or postal code.
  getter postal_code : String?

  # State, county, province, or region.
  getter state : String?

  def initialize(
    @line1 = nil,
    @line2 = nil,
    @city = nil,
    @state = nil,
    @postal_code = nil,
    @country = nil,
  )
  end

  protected def to_named_tuple
    {
      line1:       line1,
      line2:       line2,
      city:        city,
      state:       state,
      postal_code: postal_code,
      country:     country,
    }
  end
end
