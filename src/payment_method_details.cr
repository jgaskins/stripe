require "json"

require "./payment_method"

# Details about the payment method at the time of a transaction, such as a
# `Charge`. Only the `card` details are modeled so far.
struct Stripe::PaymentMethodDetails
  include JSON::Serializable

  # The type of the payment method used for the transaction.
  getter type : PaymentMethod::Type

  # Present when `type` is `PaymentMethod::Type::Card`.
  getter card : Card?

  struct Card
    include JSON::Serializable

    # The authorized amount.
    getter amount_authorized : Int64?

    # Authorization code on the charge.
    getter authorization_code : String?

    getter brand : PaymentMethod::Card::Brand?

    # When using manual capture, a future timestamp at which the charge will be
    # automatically refunded if uncaptured.
    @[JSON::Field(converter: Time::EpochConverter)]
    getter capture_before : Time?

    # Check results by Card networks on Card address and CVC at time of payment.
    getter checks : PaymentMethod::Card::Checks?

    # Two-letter ISO code representing the country of the card.
    getter country : String?

    getter exp_month : Int32
    getter exp_year : Int32

    # Uniquely identifies this particular card number. You can use this
    # attribute to check whether two customers who’ve signed up with you are
    # using the same card number.
    getter fingerprint : String?

    getter funding : PaymentMethod::Card::Funding?

    # The last four digits of the card.
    getter last4 : String?

    # Identifies which network this charge was processed on, such as `amex`,
    # `cartes_bancaires`, `mastercard`, or `visa`.
    getter network : String?

    # The card network's unique identifier for this transaction.
    getter network_transaction_id : String?

    # Populated if this transaction used 3D Secure authentication.
    getter three_d_secure : JSON::Any?

    # If this card has been tokenized, details about the digital wallet used,
    # such as Apple Pay or Google Pay.
    getter wallet : JSON::Any?
  end
end
