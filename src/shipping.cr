require "json"

require "./address"

struct Stripe::Shipping
  include JSON::Serializable

  # Customer shipping address.
  getter address : Address?

  # Customer name.
  getter name : String?

  # Customer phone (including extension).
  getter phone : String?

  # The delivery service that shipped a physical product, such as Fedex, UPS,
  # USPS, etc. Only present on PaymentIntents.
  getter carrier : String?

  # The tracking number for a physical product, obtained from the delivery
  # service. Only present on PaymentIntents.
  getter tracking_number : String?

  def initialize(
    @name = nil,
    @address = nil,
    @phone = nil,
    @carrier = nil,
    @tracking_number = nil,
  )
  end

  protected def to_named_tuple
    {
      name:            name,
      address:         address.try(&.to_named_tuple),
      phone:           phone,
      carrier:         carrier,
      tracking_number: tracking_number,
    }
  end
end
