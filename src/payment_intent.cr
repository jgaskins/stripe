require "./resource"
require "./currency"
require "./metadata"
require "./address"
require "./payment_method"
require "./automatic_payment_methods"

struct Stripe::PaymentIntent
  include Resource

  # Unique identifier for the object.
  # retrievable with publishable key
  getter id : String

  # Amount intended to be collected by this PaymentIntent. A positive integer representing how much to charge in the smallest currency unit (e.g., 100 cents to charge $1.00 or 100 to charge ¥100, a zero-decimal currency). The minimum amount is $0.50 US or equivalent in charge currency. The amount value supports up to eight digits (e.g., a value of 99999999 for a USD charge of $999,999.99).
  # retrievable with publishable key
  getter amount : Int64

  # Settings to configure compatible payment methods from the Stripe Dashboard.
  # retrievable with publishable key
  getter automatic_payment_methods : AutomaticPaymentMethods?

  # The client secret of this PaymentIntent. Used for client-side retrieval using a publishable key.
  # The client secret can be used to complete a payment from your frontend. It should not be stored, logged, or exposed to anyone other than the customer. Make sure that you have TLS enabled on any page that includes the client secret.
  # Refer to our docs to accept a payment and learn about how client_secret should be handled.
  # retrievable with publishable key
  getter client_secret : String?

  # Three-letter ISO currency code, in lowercase. Must be a supported currency.
  # retrievable with publishable key
  getter currency : Currency

  # ID of the Customer this PaymentIntent belongs to, if one exists.
  # Payment methods attached to other Customers cannot be used with this PaymentIntent.
  # If setup_future_usage is set and this PaymentIntent’s payment method is not card_present, then the payment method attaches to the Customer after the PaymentIntent has been confirmed and any required actions from the user are complete. If the payment method is card_present and isn’t a digital wallet, then a generated_card payment method representing the card is created and attached to the Customer instead.
  getter customer : String?

  # An arbitrary string attached to the object. Often useful for displaying to users.
  # retrievable with publishable key
  getter description : String?

  # The payment error encountered in the previous PaymentIntent confirmation. It will be cleared if the PaymentIntent is later updated for any reason.
  # retrievable with publishable key
  getter last_payment_error : PaymentError?

  struct PaymentError
    include Resource
  end

  # ID of the latest Charge object created by this PaymentIntent. This property is null until PaymentIntent confirmation is attempted.
  getter latest_charge : String?

  # Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. Learn more about storing information in metadata.
  getter metadata : Metadata

  # If present, this property tells you what actions you need to take in order for your customer to fulfill a payment using the provided source.
  getter next_action : Hash(String, JSON::Any)?

  # ID of the payment method used in this PaymentIntent.
  # NOTE: retrievable with publishable key
  getter payment_method : String | PaymentMethod | Nil

  # Email address that the receipt for the resulting payment will be sent to. If receipt_email is specified for a payment in live mode, a receipt will be sent regardless of your email settings.
  # retrievable with publishable key
  getter receipt_email : String?

  # Indicates that you intend to make future payments with this PaymentIntent’s payment method.
  # If you provide a Customer with the PaymentIntent, you can use this parameter to attach the payment method to the Customer after the PaymentIntent is confirmed and the customer completes any required actions. If you don’t provide a Customer, you can still attach the payment method to a Customer after the transaction completes.
  # If the payment method is card_present and isn’t a digital wallet, Stripe creates and attaches a generated_card payment method representing the card to the Customer instead.
  # When processing card payments, Stripe uses setup_future_usage to help you comply with regional legislation and network rules, such as SCA.
  # retrievable with publishable key
  getter setup_future_usage : SetupFutureUsage?

  enum SetupFutureUsage
    # Use `OffSession` if your customer may or may not be present in your checkout flow.
    OffSession

    # Use `OnSession` if you intend to only reuse the payment method when your customer is present in your checkout flow.
    OnSession
  end

  # Shipping information for this PaymentIntent.
  # retrievable with publishable key
  getter shipping : Address?

  # Text that appears on the customer’s statement as the statement descriptor for a non-card charge. This value overrides the account’s default statement descriptor. For information about requirements, including the 22-character limit, see the Statement Descriptor docs.
  # Setting this value for a card charge returns an error. For card charges, set the statement_descriptor_suffix instead.
  getter statement_descriptor : String?

  # Provides information about a card charge. Concatenated to the account’s statement descriptor prefix to form the complete statement descriptor that appears on the customer’s statement.
  getter statement_descriptor_suffix : String?

  # enum
  # retrievable with publishable key
  # Status of this PaymentIntent, one of requires_payment_method, requires_confirmation, requires_action, processing, requires_capture, canceled, or succeeded. Read more about each PaymentIntent status.
  getter status : Status

  # Status of a `PaymentIntent`. Read more about each [`PaymentIntent` status](https://docs.stripe.com/payments/paymentintents/lifecycle#intent-statuses).
  enum Status
    # You can cancel a `PaymentIntent` at any point before it’s in a `Processing` or `Succeeded` state. Canceling it invalidates the `PaymentIntent` for future payment attempts, and can’t be undone. If any funds have been held, cancellation releases them.
    #
    # `PaymentIntent`s might also be automatically transitioned to the canceled state after they have been confirmed too many times.
    Canceled

    # After required actions are handled, the `PaymentIntent` moves to processing for asynchronous payment methods, such as bank debits. These types of payment methods can take up to a few days to process. Other payment methods, such as cards, are processed more quickly and don’t go into the processing status.
    #
    # If you’re separately [authorizing and capturing funds](https://docs.stripe.com/payments/place-a-hold-on-a-payment-method), your `PaymentIntent` can instead move to `RequiresCapture`. In that case, attempting to capture the funds moves it to processing.
    Processing

    # If the payment requires additional actions, such as authenticating with 3D Secure, the PaymentIntent has a status of requires_action.
    RequiresAction

    RequiresCapture

    # After the customer provides their payment information, the PaymentIntent is ready to be confirmed.
    #
    # In most integrations, this state is skipped because payment method information is submitted at the same time that the payment is confirmed.
    RequiresConfirmation

    # When the PaymentIntent is created, it has a status of requires_payment_method1 until a payment method is attached.
    #
    # We recommend creating the PaymentIntent as soon as you know how much you want to charge, so that Stripe can record all the attempted payments.
    RequiresPaymentMethod

    # A `PaymentIntent` with a status of succeeded means that the payment flow it is driving is complete.
    #
    # The funds are now in your account and you can confidently fulfill the order. If you need to refund the customer, you can use the Refunds API.
    Succeeded
  end

  # String representing the object’s type. Objects of the same type share the same value.
  # retrievable with publishable key
  getter object : String

  # Amount that can be captured from this PaymentIntent.
  getter amount_capturable : Int64

  # Provides industry-specific information about the amount.
  getter amount_details : AmountDetails?

  Resource.define AmountDetails do
    getter tip : Tip?

    Resource.define Tip do
      getter amount : Int64?
    end
  end

  # Amount that this PaymentIntent collects.
  getter amount_received : Int64

  # NOTE: Expandable
  # NOTE: Connect only
  getter application : String?

  # NOTE: Connect only
  getter application_fee_amount : Int64?

  @[JSON::Field(converter: Time::EpochConverter)]
  # Populated when `status` is `Status::Canceled`, this is the time at which the `PaymentIntent` was canceled.
  # NOTE: retrievable with publishable key
  getter canceled_at : Time?

  # Reason for cancellation of this PaymentIntent, either user-provided (duplicate, fraudulent, requested_by_customer, or abandoned) or generated by Stripe internally (failed_invoice, void_invoice, or automatic).
  # NOTE: retrievable with publishable key
  getter cancellation_reason : CancellationReason?

  enum CancellationReason
    Duplicate
    Fraudulent
    RequestedByCustomer
    Abandoned

    FailedInvoice
    VoidInvoice
    Automatic
  end

  # capture_method
  # enum
  # retrievable with publishable key

  # confirmation_method
  # enum
  # retrievable with publishable key

  # created
  # timestamp
  # retrievable with publishable key

  # invoice
  # nullable string
  # Expandable

  # livemode
  # boolean
  # retrievable with publishable key

  # on_behalf_of
  # nullable string
  # Expandable
  # Connect only

  # payment_method_configuration_details
  # nullable dictionary

  # payment_method_options
  # nullable dictionary

  # payment_method_types
  # array of strings
  # retrievable with publishable key

  # processing
  # nullable dictionary
  # retrievable with publishable key

  # review
  # nullable string
  # Expandable

  # transfer_data
  # nullable dictionary
  # Connect only

  # transfer_group
  # nullable string
  # Connect only
end
