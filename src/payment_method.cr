require "./resource"
require "./address"
require "./customer"
require "./test_card"

struct Stripe::PaymentMethod
  include Resource

  getter id : String
  getter billing_details : BillingDetails
  getter customer : String | Customer | Nil
  getter metadata : Metadata = Metadata.new
  getter type : Type
  getter object : String
  getter allow_redisplay : AllowRedisplay?
  getter card : Card?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter? livemode : Bool

  define Card do
    getter! brand : Brand
    getter checks : Checks?
    getter country : String?
    getter display_brand : String?
    getter exp_month : Int8
    getter exp_year : Int16
    getter number : String?
    getter fingerprint : String?
    getter! funding : Funding
    getter generated_from : GeneratedFrom?
    getter! last4 : String
    getter! networks : JSON::Any
    getter! three_d_secure_usage : JSON::Any
    getter! wallet : JSON::Any

    def initialize(
      *,
      @brand = nil,
      @checks = nil,
      @country = nil,
      @display_brand = nil,
      exp_month,
      exp_year,
      @number = nil,
      @fingerprint = nil,
      @funding = nil,
      @generated_from = nil,
      @last4 = nil,
      @networks = nil,
      @three_d_secure_usage = nil,
      @wallet = nil,
    )
      @exp_month = exp_month.to_i8
      @exp_year = exp_year.to_i16
    end

    define GeneratedFrom do
      getter charge : String?
      getter payment_method_details : PaymentMethodDetails?
      getter setup_attempt : String

      define PaymentMethodDetails do
        getter card_present : JSON::Any
        getter type : String
      end
    end

    enum Funding
      Credit
      Debit
      Prepaid
      Unknown
    end

    define Checks do
      getter address_line1_check : Check?
      getter address_postal_code_check : Check?
      getter cvc_check : Check?

      enum Check
        Pass
        Fail
        Unavailable
        Unchecked
      end
    end

    enum Brand
      AMEX
      Diners
      Discover
      EFTPOS_AU
      JCB
      Mastercard
      Unionpay
      Visa
      Unknown
    end
  end

  enum AllowRedisplay
    Always
    Limited
    Unspecified
  end

  Resource.define BillingDetails do
    getter address : Address?
    getter email : String?
    getter name : String?
    getter phone : String?
  end

  enum Type
    # Pre-authorized debit payments are used to debit Canadian bank accounts through the Automated Clearing Settlement System (ACSS).
    ACSSDebit

    # Affirm is a buy now, pay later payment method in the US.
    Affirm

    # Afterpay / Clearpay is a buy now, pay later payment method used in Australia, Canada, France, New Zealand, Spain, the UK, and the US.
    AfterpayClearpay

    # Alipay is a digital wallet payment method used in China.
    Alipay

    # Amazon Pay is a Wallet payment method that lets hundreds of millions of Amazon customers pay their way, every day.
    AmazonPay

    # BECS Direct Debit is used to debit Australian bank accounts through the Bulk Electronic Clearing System (BECS).
    AU_BECSDebit

    # Bacs Direct Debit is used to debit UK bank accounts.
    BACSDebit

    # Bancontact is a bank redirect payment method used in Belgium.
    Bancontact

    # BLIK is a single-use payment method common in Poland.
    BLIK

    # Boleto is a voucher-based payment method used in Brazil.
    Boleto

    # Card payments are supported through many networks and card brands.
    Card

    # Stripe Terminal is used to collect in-person card payments.
    CardPresent

    # Cash App Pay enables customers to frictionlessly authenticate payments in the Cash App using their stored balance or linked card.
    Cashapp

    # Uses a customer’s cash balance for the payment.
    CustomerBalance

    # EPS is an Austria-based bank redirect payment method.
    EPS

    # FPX is a Malaysia-based bank redirect payment method.
    FPX

    # giropay is a German bank redirect payment method.
    Giropay

    # GrabPay is a digital wallet payment method used in Southeast Asia.
    Grabpay

    # iDEAL is a Netherlands-based bank redirect payment method.
    IDEAL

    # Stripe Terminal accepts Interac debit cards for in-person payments in Canada.
    InteracPresent

    # Klarna is a global buy now, pay later payment method.
    Klarna

    # Konbini is a cash-based voucher payment method used in Japan.
    Konbini

    # Link allows customers to pay with their saved payment details.
    Link

    # MobilePay is a Nordic card-passthrough wallet payment method where customers authorize the payment in the MobilePay application.
    Mobilepay

    # Multibanco is a voucher payment method
    Multibanco

    # OXXO is a cash-based voucher payment method used in Mexico.
    OXXO

    # Przelewy24 is a bank redirect payment method used in Poland.
    P24

    # PayNow is a QR code payment method used in Singapore.
    Paynow

    # PayPal is an online wallet and redirect payment method commonly used in Europe.
    Paypal

    # Pix is an instant bank transfer payment method in Brazil.
    Pix

    # PromptPay is an instant funds transfer service popular in Thailand.
    Promptpay

    # Revolut Pay is a digital wallet payment method used in the United Kingdom.
    RevolutPay

    # SEPA Direct Debit is used to debit bank accounts within the Single Euro Payments Area (SEPA) region.
    SEPADebit

    # Sofort is a bank redirect payment method used in Europe.
    Sofort

    # Swish is a Swedish wallet payment method where customers authorize the payment in the Swish application.
    Swish

    # TWINT is a payment method.
    TWINT

    # ACH Direct Debit is used to debit US bank accounts through the Automated Clearing House (ACH) payments system.
    USBankAccount

    # WeChat Pay is a digital wallet payment method based in China.
    WECHAT_PAY

    # Zip is a Buy now, pay later Payment Method
    Zip
  end

end
