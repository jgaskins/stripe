# We need the Stripe::Checkout namespace to be defined because it's not a module
# and we don't want to be responsible for defining the hierarchy here
require "./sessions"

require "../resource"
require "../currency"
require "../tax_exemption"

struct Stripe::Checkout::Session
  include Resource

  getter id : String
  getter client_reference_id : String?
  getter currency : Currency
  getter customer : String?
  getter customer_email : String?
  getter line_items : List(LineItem)?
  getter metadata : Metadata { Metadata.new }
  getter mode : Mode
  getter payment_intent : String?
  getter payment_status : PaymentStatus
  getter return_url : String?
  getter status : Status
  getter success_url : String?
  getter url : String?
  getter object : String
  getter after_expiration : AfterExpiration?
  getter? allow_promotion_codes : Bool?
  getter amount_subtotal : Int64?
  getter amount_total : Int64?
  getter automatic_tax : AutomaticTax
  getter billing_address_collection : BillingAddressCollection?
  getter cancel_url : String?
  getter client_secret : String?
  getter consent : Consent?
  getter consent_collection : ConsentCollection?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter currency_conversion : CurrencyConversion?
  getter custom_fields : Array(CustomField)
  getter custom_text : CustomText
  getter customer_creation : CustomerCreation
  getter customer_details : CustomerDetails?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter expires_at : Time
  getter invoice : String?
  getter invoice_creation : InvoiceCreation?
  getter? livemode : Bool = false
  getter locale : String?
  getter payment_link : String?
  getter payment_method_collection : PaymentMethodCollection?
  getter payment_method_configuration_details : PaymentMethodConfigurationDetails?
  getter payment_method_options : Hash(String, JSON::Any)?
  getter payment_method_types : Array(String)
  getter phone_number_collection : PhoneNumberCollection?
  getter recovered_from : String?
  getter redirect_on_completion : RedirectOnCompletion?
  getter saved_payment_method_options : Hash(String, JSON::Any)?
  getter setup_intent : String?
  getter shipping_address_collection : JSON::Any
  getter shipping_cost : JSON::Any
  getter shipping_details : JSON::Any?
  getter shipping_options : JSON::Any?
  getter submit_type : SubmitType?
  getter subscription : String?
  getter tax_id_collection : TaxIDCollection?
  getter total_details : TotalDetails?
  getter ui_mode : UIMode?

  enum UIMode
    Embedded
    Hosted
  end

  struct TotalDetails
    include Resource

    getter amount_discount : Int64
    getter amount_shipping : Int64?
    getter amount_tax : Int64
    getter breakdown : Breakdown?

    struct Breakdown
      include Resource

      getter discounts : Array(JSON::Any)
      getter taxes : Array(JSON::Any)
    end
  end

  struct TaxIDCollection
    include Resource

    getter? enabled : Bool
    getter required : Required

    enum Required
      IfSupported
      Never
    end
  end

  enum SubmitType
    Auto
    Book
    Donate
    Pay
  end

  enum RedirectOnCompletion
    Always
    IfRequired
    Never
  end

  struct PhoneNumberCollection
    include Resource

    getter? enabled : Bool
  end

  struct PaymentMethodConfigurationDetails
    include Resource

    getter id : String
    getter parent : String?
  end

  enum PaymentMethodCollection
    Always
    IfRequired
  end

  struct InvoiceCreation
    include Resource

    getter? enabled : Bool
    getter invoice_data : InvoiceData
  end

  struct InvoiceData
    include Resource
    getter account_tax_ids : Array(String)?
    getter custom_fields : Array(CustomField)?
    getter description : String?
    getter footer : String?
    getter metadata : Metadata { Metadata.new }
    getter rendering_options : RenderingOptions?

    struct RenderingOptions
      include Resource

      getter amount_tax_display : String?
    end
  end

  struct CustomerDetails
    include Resource

    getter address : Address?
    getter email : String?
    getter name : String?
    getter phone : String?
    getter tax_exempt : TaxExemption
    getter tax_ids : Array(TaxID)?

    struct TaxID
      include Resource

      getter type : Type
      getter value : String?

      enum Type
        AD_NRT
        AE_TRN
        AR_CUIT
        AU_ABN
        AU_ARN
        BG_UIC
        BH_VAT
        BO_TIN
        BR_CNPJ
        BR_CPF
        CA_BN
        CA_GST_HST
        CA_PST_BC
        CA_PST_MB
        CA_PST_SK
        CA_QST
        CH_UID
        CH_VAT
        CL_TIN
        CN_TIN
        CO_NIT
        CR_TIN
        DE_STN
        DO_RCN
        EC_RUC
        EG_TIN
        ES_CIF
        EU_OSS_VAT
        EU_VAT
        GB_VAT
        GE_VAT
        HK_BR
        HR_OIB
        HU_TIN
        ID_NPWP
        IL_VAT
        IN_GST
        IS_VAT
        JP_CN
        JP_RN
        JP_TRN
        KE_PIN
        KR_BRN
        KZ_BIN
        LI_UID
        MX_RFC
        MY_FRP
        MY_ITN
        MY_SST
        NG_TIN
        NO_VAT
        NO_VOEC
        NZ_GST
        OM_VAT
        PE_RUC
        PH_TIN
        RO_TIN
        RS_PIB
        RU_INN
        RU_KPP
        SA_VAT
        SG_GST
        SG_UEN
        SI_TIN
        SV_NIT
        TH_VAT
        TR_TIN
        TW_VAT
        UA_VAT
        Unknown
        US_EIN
        UY_RUC
        VE_RIF
        VN_TIN
        ZA_VAT
      end
    end
  end

  enum CustomerCreation
    Always
    IfRequired
  end

  struct CustomText
    include Resource

    getter after_submit : Message?
    getter shipping_address : Message?
    getter submit : Message?
    getter terms_of_service_acceptabce : Message?

    struct Message
      include Resource

      getter message : String
    end
  end

  enum Type
    Dropdown
    Numeric
    Text
  end

  # getter numeric : Value?
  # getter? optional : Bool
  # getter text : Value?
  # getter type : Type
  struct Value
    include Resource

    getter default_value : String?
    getter maximum_length : Int64?
    getter minimum_length : Int64?
    getter value : String?
  end

  struct CustomField
    include Resource

    getter dropdown : Dropdown
    getter key : String
    getter label : Label

    struct Label
      include Resource

      getter custom : String?
      getter type : Type

      enum Type
        Custom
      end
    end

    struct Dropdown
      include Resource

      getter default_value : String?
      getter options : Array(Option)
      getter value : String?

      struct Option
        include Resource
        getter label : String
        getter value : String
      end
    end
  end

  struct CurrencyConversion
    include Resource

    getter amount_subtotal : Int64
    getter amount_total : Int64
    getter fx_rate : String
    getter source_currency : String
  end

  struct ConsentCollection
    include Resource

    getter payment_method_reuse_agreement : PaymentMethodReuseAgreement?
    getter promotions : Promotions?
    getter terms_of_service : TermsOfService?

    enum Promotions
      Auto
      None
    end

    enum TermsOfService
      None
      Required
    end

    struct PaymentMethodReuseAgreement
      include Resource

      getter position : Position

      enum Position
        Auto
        Hidden
      end
    end
  end

  struct Consent
    include Resource

    getter promotions : Promotions?
    getter terms_of_service : TermsOfService?

    enum Promotions
      OptIn
      OptOut
    end

    enum TermsOfService
      Accepted
    end
  end

  enum BillingAddressCollection
    Auto
    Required
  end

  struct AutomaticTax
    include Resource

    getter? enabled : Bool
    getter liability : Liability?
    getter status : Status?

    enum Status
      Complete
      Failed
      RequiresLocationInputs
    end

    struct Liability
      include Resource

      getter account : String?
      getter type : Type

      enum Type
        Account
        Self
      end
    end
  end

  struct AfterExpiration
    include Resource

    getter recovery : Recovery?

    struct Recovery
      include Resource

      getter? allow_promotion_codes : Bool
      getter? enabled : Bool
      @[JSON::Field(converter: Time::EpochConverter)]
      getter? expires_at : Time
      getter url : String?
    end
  end

  enum Status
    Complete
    Expired
    Open
  end

  enum PaymentStatus
    NoPaymentRequired
    Paid
    Unpaid
  end

  enum Mode
    Payment
    Setup
    Subscription
  end
end
