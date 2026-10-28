require "./resource"
require "./currency"
require "./charge"
require "./payment_intent"

struct Stripe::Refund
  include JSON::Serializable

  getter id : String
  getter amount : Int64
  getter charge : String | Charge | Nil
  getter currency : Currency
  getter payment_intent : String | PaymentIntent | Nil
  getter status : Status
  getter reason : Reason?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time

  enum Status
    Pending
    RequiresAction
    Succeeded
    Failed
    Canceled
  end

  enum Reason
    Duplicate
    Fraudulent
    RequestedByCustomer
    ExpiredUncapturedCharge
  end
end
