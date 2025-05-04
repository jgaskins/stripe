require "./resource"
require "./metadata"
require "./customer"
require "./payment_method"
require "./automatic_payment_methods"

struct Stripe::SetupIntent
  include Resource

  getter id : String
  getter automatic_payment_methods : AutomaticPaymentMethods?
  getter client_secret : String?
  getter customer : String | Customer | Nil
  getter description : String?
  getter last_setup_error : SetupError?
  getter metadata : Metadata
  getter next_action : NextAction?
  getter payment_method : String | PaymentMethod | Nil
  getter status : Status
  getter usage : Usage
  getter? livemode : Bool
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter application : String?
  getter? attach_to_self : Bool?
  getter cancellation_reason : CancellationReason?
  getter flow_directions : Array(FlowDirection) { [] of FlowDirection }
  getter latest_attempt : String?
  getter mandate : String?
  getter on_behalf_of : String?
  getter payment_method_configuration_details : PaymentMethodConfigurationDetails?
  getter payment_method_options : JSON::Any?
  getter payment_method_types : Array(PaymentMethod::Type)
  getter? single_use_mandate : String?

  struct PaymentMethodConfigurationDetails
    include Resource

    getter id : String
    getter parent : String?
  end

  enum FlowDirection
    Inbound
    Outbound
  end

  enum CancellationReason
    Abandoned
    Duplicate
    RequestedByCustomer
  end

  struct SetupError
    include Resource
    getter advice_code : String?
    getter code : String?
    getter decline_code : String?
    getter doc_url : String?
    getter message : String?
    getter network_advice_code : String?
    getter network_decline_code : String?
    getter param : String?
    getter payment_method : PaymentMethod?
    getter payment_method_type : String?
    getter type : Type

    enum Type
      APIError
      CardError
      IdempotencyError
      InvalidRequestError
    end
  end

  struct NextAction
    include Resource

    getter cashapp_handle_redirect_or_display_qr_code : CashAppQRCode?
    getter redirect_to_url : RedirectToURL
    getter type : Type
    getter use_stripe_sdk : UseStripeSDK?
    getter verify_with_microdeposits : VerifyWithMicrodeposits?

    enum Type
      RedirectToURL
      UseStripeSDK
      AlipayHandleRedirect
      OXXODisplayDetails
      VerifyWithMicrodeposits
    end

    struct RedirectToURL
      include Resource

      getter return_url : String?
      getter url : String?
    end

    struct UseStripeSDK
      include Resource
      include JSON::Serializable::Unmapped
    end

    struct VerifyWithMicrodeposits
      include Resource

      @[JSON::Field(converter: Time::EpochConverter)]
      getter arrival_date : Time
      getter hosted_verification_url : String
      getter microdeposit_type : String?
    end

    struct CashAppQRCode
      include Resource
      getter hosted_instructions_url : String
      getter mobile_auth_url : String
      getter qr_code : QRCode

      struct QRCode
        include Resource

        @[JSON::Field(converter: Time::EpochConverter)]
        getter expires_at : Time
        getter image_url_png : String
        getter image_url_svg : String
      end
    end
  end

  enum Status
    Canceled
    Processing
    RequiresAction
    RequiresConfirmation
    RequiresPaymentMethod
    Succeeded
  end

  enum Usage
    OffSession
    OnSession
  end
end
