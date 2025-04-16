require "./resource"
require "./subscription"
require "./customer"
require "./invoice"
require "./payment_method"
require "./plan"
require "./setup_intent"
require "./checkout/session"
require "./price"
require "./product"

abstract struct Stripe::Webhook
  include Resource

  DEFAULT_TOLERANCE = 5.minutes

  # The Stripe identifier for this webhook
  getter id : String

  # The object type, which should always be `"webhook"`.
  getter object : String

  # The Stripe API version this webhook conforms to.
  getter api_version : String

  @[JSON::Field(converter: Time::EpochConverter)]
  # The time that this webhook was first sent.
  getter created : Time

  # Returns `true` if this was sent from your live Stripe environment, `false` if it was from a test or sandbox environment.
  getter? livemode : Bool

  # The number of pending webhooks.
  getter pending_webhooks : Int64

  getter request : Request

  # The type of webhook, indicating the Crystal type — for example, the value `"customer.created"` here indicates that the event will be an instance of `Stripe::Webhook::Customer::Created`.
  getter type : String

  # The data associated with the webhook event, specific to that type of webhook.
  abstract def data

  {% for method_name in %w[from_request raw_from_request].map(&.id) %}
    def self.{{method_name}}(request, webhook_secret, tolerance = DEFAULT_TOLERANCE)
      if body = request.body
        {{method_name}} request, webhook_secret, body, tolerance
      end
    end

    def self.{{method_name}}(request, webhook_secret, body : IO, tolerance = DEFAULT_TOLERANCE)
      {{method_name}} request, webhook_secret, body.gets_to_end, tolerance
    end
  {% end %}

  def self.raw_from_request(request, webhook_secret, body : String, tolerance = DEFAULT_TOLERANCE) : String?
    handle_request request, webhook_secret, body, tolerance do |body|
      return body
    end
  end

  def self.from_request(request, webhook_secret, body : String, tolerance = DEFAULT_TOLERANCE) : Webhook?
    handle_request request, webhook_secret, body, tolerance do |body|
      return from_json body
    end
  end

  private def self.handle_request(request, webhook_secret : String, body : String, tolerance : Time::Span) : Nil
    if (signature_header = request.headers["Stripe-Signature"]?)
      return nil unless timestamp_match = signature_header.match(/t=(\d+)/)

      # The webhook can't be too long ago, to mitigate replay attacks
      timestamp = Time.unix(timestamp_match[1].to_i64)
      return nil if Time.utc - timestamp > tolerance

      signature_header.scan(/v1=(\w+)/) do |match|
        signature = match[1]
        timestamped_payload = "#{timestamp_match[1]}.#{body}"
        expected_signature = OpenSSL::HMAC.hexdigest(:sha256, webhook_secret, timestamped_payload)

        if Crypto::Subtle.constant_time_compare expected_signature, signature
          return yield body
        end
      end
    end
  end

  struct Request
    include Resource

    getter id : String?
    getter idempotency_key : String?
  end

  private macro namespace(name)
    abstract struct {{name}} < self
      {{yield}}
    end
  end

  private macro event(name)
    struct {{name}} < self
      {{yield}}
    end
  end

  private macro data(type)
    getter data : Wrapper(Stripe::{{type}})
  end

  # Use this macro when stubbing out event types.
  private macro stub_data
    getter data : JSON::Any
  end

  private macro define_enable(name)
    # Allow deserialization of `{{name}}.*` events
    macro enable_{{name}}
      struct ::Stripe::Webhook
        {{yield}}
      end
    end
  end

  define_enable account do
    namespace Account do
      event Updated do
        stub_data
      end

      namespace ExternalAccount do
        stub_data
        event Created
        event Deleted
        event Updated
      end
    end
  end

  define_enable balance do
    namespace Balance do
      stub_data
      event Available
    end
  end

  define_enable billing do
    namespace Billing do
      namespace Alert do
        stub_data
        event Triggered
      end
    end
  end

  define_enable capability do
    namespace Capability do
      stub_data
      event Updated
    end
  end

  define_enable cash_balance do
    namespace CashBalance do
      stub_data
      event FundsAvailable
    end
  end

  define_enable charge do
    namespace Charge do
      private macro define_event(type)
        event \{{type}} do
          # data Charge
          \{{yield}}
        end
      end

      stub_data
      event Captured
      namespace Dispute do
        # data Dispute
        stub_data
        event Closed
        event Created
        event FundsReinstated
        event FundsWithdrawn
        event Updated
      end
      event Expired
      event Failed
      event Pending
      namespace Refund do
        # data Refund
        stub_data
        event Updated
      end
      event Refunded
      event Succeeded
      event Updated
    end
  end

  define_enable checkout do
    namespace Checkout do
      namespace Session do
        data Checkout::Session

        event Completed
        event AsyncPaymentFailed
        event AsyncPaymentSucceeded
        event Completed
        event Expired
      end
    end
  end

  define_enable climate do
    namespace Climate do
      namespace Order do
        # data Climate::Order
        stub_data
        event Canceled
        event Created
        event Delayed
        event Delivered
        event ProductSubstituted
      end

      namespace Product do
        # data Climate::Product
        stub_data
        event Created
        event PricingUpdated
      end
    end
  end

  define_enable coupon do
    namespace Coupon do
      # data Coupon
      stub_data
      event Created
      event Deleted
      event Updated
    end
  end

  define_enable credit_note do
    namespace CreditNote do
      # data CreditNote
      stub_data
      event Created
      event Deleted
      event Updated
      event Voided
    end
  end

  define_enable customer_cash_balance_transaction do
    namespace CustomerCashBalanceTransaction do
      # data CustomerCashBalanceTransaction
      stub_data
      event Created
    end
  end

  define_enable customer do
    namespace Customer do
      macro define_event(name)
        event \{{name}} do
          data Customer
        end
      end

      define_event Created
      define_event Updated

      namespace Discount do
        # data Discount
        stub_data
        event Created
        event Deleted
        event Updated
      end

      namespace Source do
        # data Source
        stub_data
        event Created
        event Deleted
        event Expiring
        event Updated
      end

      namespace Subscription do
        getter data : Wrapper(Stripe::Subscription)

        event Created
        event Deleted
        event Paused
        event PendingUpdateApplied
        event PendingUpdateExpired
        event Resumed
        event TrialWillEnd
        event Updated
      end

      namespace TaxID do
        # data TaxID
        stub_data
        event Created
        event Deleted
        event Updated
      end
    end
  end

  define_enable entitlements do
    namespace Entitlements do
      namespace ActiveEntitlementSummary do
        stub_data
        event Updated
      end
    end
  end

  define_enable file do
    namespace File do
      stub_data
      event Created
    end
  end

  define_enable financial_connections do
    namespace FinancialConnections do
      namespace Account do
        stub_data
        event Created
        event Deactivated
        event Disconnected
        event Reactivated
        event RefreshedBalance
        event RefreshedOwnership
        event RefreshedTransactions
      end
    end
  end

  define_enable identity do
    namespace Identity do
      namespace VerificationSession do
        # data Identity::VerificationSession
        stub_data
        event Canceled
        event Created
        event Processing
        event Redacted
        event RequiresInput
        event Verified
      end
    end
  end

  define_enable invoice do
    namespace Invoice do
      # data Invoice
      stub_data
      event Created
      event Deleted
      event FinalizationFailed
      event Finalized
      event MarkedUncollectible
      event Overdue
      event Paid
      event PaymentActionRequired
      event PaymentFailed
      event PaymentSucceeded
      event Sent
      event Upcoming
      event Updated
      event Voided
      event WillBeDue
    end
  end

  define_enable invoiceitem do
    namespace Invoiceitem do
      stub_data
      event Created
      event Deleted
    end
  end

  define_enable issuing_authorization do
    namespace IssuingAuthorization do
      stub_data
      event Created
      event Request
      event Updated
    end
  end

  define_enable issuing_card do
    namespace IssuingCard do
      stub_data
      event Created
      event Updated
    end
  end

  define_enable issuing_cardholder do
    namespace IssuingCardholder do
      stub_data
      event Created
      event Updated
    end
  end

  define_enable issuing_dispute do
    namespace IssuingDispute do
      stub_data
      event Closed
      event Created
      event FundsReinstated
      event FundsRescinded
      event Submitted
      event Updated
    end
  end

  define_enable issuing_personalization_design do
    namespace IssuingPersonalizationDesign do
      stub_data
      event Activated
      event Deactivated
      event Rejected
      event Updated
    end
  end

  define_enable issuing_token do
    namespace IssuingToken do
      stub_data
      event Created
      event Updated
    end
  end

  define_enable issuing_transaction do
    namespace IssuingTransaction do
      stub_data
      event Created
      event Updated
    end
  end

  define_enable mandate do
    namespace Mandate do
      stub_data
      event Updated
    end
  end

  define_enable payment_intent do
    namespace PaymentIntent do
      stub_data
      event AmountCapturableUpdated
      event Canceled
      event Created
      event PartiallyFunded
      event PaymentFailed
      event Processing
      event RequiresAction
      event Succeeded
    end
  end

  define_enable payment_link do
    namespace PaymentLink do
      stub_data
      event Created
      event Updated
    end
  end

  define_enable payment_method do
    namespace PaymentMethod do
      data PaymentMethod
      event Attached
      event AutomaticallyUpdated
      event Detached
      event Updated
    end
  end

  define_enable payout do
    namespace Payout do
      stub_data
      event Canceled
      event Created
      event Failed
      event Paid
      event ReconciliationCompleted
      event Updated
    end
  end

  define_enable person do
    namespace Person do
      stub_data
      event Created
      event Deleted
      event Updated
    end
  end

  define_enable plan do
    namespace Plan do
      data Plan
      event Created
      event Deleted
      event Updated
    end
  end

  define_enable price do
    namespace Price do
      data Price
      event Created
      event Deleted
      event Updated
    end
  end

  define_enable product do
    namespace Product do
      data Product
      event Created
      event Deleted
      event Updated
    end
  end

  define_enable promotion_code do
    namespace PromotionCode do
      stub_data
      event Created
      event Updated
    end
  end

  define_enable quote do
    namespace Quote do
      stub_data
      event Accepted
      event Canceled
      event Created
      event Finalized
      event WillExpire
    end
  end

  define_enable radar do
    namespace Radar do
      stub_data
      namespace EarlyFraudWarning do
        event Created
        event Updated
      end
    end
  end

  define_enable refund do
    namespace Refund do
      stub_data
      event Created
      event Updated
    end
  end

  define_enable reporting do
    namespace Reporting do
      stub_data
      namespace ReportRun do
        event Failed
        event Succeeded
      end
      namespace ReportType do
        event Updated
      end
    end
  end

  define_enable review do
    namespace Review do
      stub_data
      event Closed
      event Opened
    end
  end

  define_enable setup_intent do
    namespace SetupIntent do
      data SetupIntent
      event Canceled
      event Created
      event RequiresAction
      event SetupFailed
      event Succeeded
    end
  end

  define_enable sigma do
    namespace Sigma do
      stub_data
      namespace ScheduledQueryRun do
        event Created
      end
    end
  end

  define_enable source do
    namespace Source do
      stub_data
      event Canceled
      event Chargeable
      event Failed
      event MandateNotification
      event RefundAttributesRequired

      namespace Transaction do
        event Created
        event Updated
      end
    end
  end

  define_enable subscription_schedule do
    namespace SubscriptionSchedule do
      stub_data
      event Aborted
      event Canceled
      event Completed
      event Created
      event Expiring
      event Released
      event Updated
    end
  end

  define_enable tax_rate do
    namespace TaxRate do
      stub_data
      event Created
      event Updated
      namespace Settings do
        event Updated
      end
    end
  end

  define_enable terminal do
    namespace Terminal do
      namespace Reader do
        stub_data
        event ActionFailed
        event ActionSucceeded
      end
    end
  end

  define_enable test_helpers do
    namespace TestHelpers do
      stub_data
      namespace TestClock do
        event Advancing
        event Created
        event Deleted
        event InternalFailure
        event Ready
      end
    end
  end

  define_enable topup do
    namespace Topup do
      stub_data
      event Canceled
      event Created
      event Failed
      event Reversed
      event Succeeded
    end
  end

  define_enable transfer do
    namespace Transfer do
      stub_data
      event Created
      event Reversed
      event Updated
    end
  end

  struct Wrapper(T)
    include Resource

    getter object : T
  end

  macro handle(types)
    {% types = [types] unless types.is_a? ArrayLiteral %}
    abstract struct Stripe::Webhook
      {% for type in types %}
        enable_{{type.id.gsub(/\AStripe::Webhook::/, "").gsub(/:.*/, "").underscore}}
      {% end %}
      use_json_discriminator "type", {
        {% for type in types %}
          {{type.id.gsub(/\AStripe::Webhook::/, "").stringify.underscore.gsub(/::/, ".")}}: {{type}},
        {% end %}
      }
    end
  end

  macro handle_all
    {{ run "../load_webhooks" }}
  end
end
