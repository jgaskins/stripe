require "./resource"
require "./customer"
require "./currency"

struct Stripe::Card
  include Resource

  getter address_city : String?
  getter address_country : String?
  getter address_line1 : String?
  getter address_line2 : String?
  getter address_state : String?
  getter address_zip : String?
  getter address_zip_check : String?
  getter brand : String
  getter country : String?
  getter customer : String | Customer | Nil
  getter cvc_check : String?
  getter exp_month : Int8
  getter exp_year : Int16
  getter fingerprint : String?
  getter funding : Funding
  getter last4 : String
  getter name : String?
  getter address_line1_check : String?
  getter allow_redisplay : AllowRedisplay?
  getter available_payout_methods : AvailablePayoutMethods
  getter currency : Currency?
  getter dynamic_last4 : String?
  getter regulated_status : RegulatedStatus?
  getter tokenization_method : Tokenizationmethod?

  enum Funding
    Credit
    Debit
    Prepaid
    Unknown
  end

  enum AllowRedisplay
    Always
    Limited
    Unspecified
  end

  @[Flags]
  enum AvailablePayoutMethods
    Instant
    Standard
  end

  enum RegulatedStatus
    Regulated
    Unregulated
  end

  enum Tokenizationmethod
    AndroidPay
    ApplePay
    Masterpass
    VisaCheckout
  end
end
