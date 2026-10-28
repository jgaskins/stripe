require "./resource"
require "./currency"
require "./customer"
require "./list"
require "./metadata"
require "./payment_method_details"
require "./refund"
require "./shipping"

struct Stripe::Charge
  include Resource

  getter amount : Int64
  getter balance_transaction : String?
  getter billing_details : BillingDetails
  getter currency : Currency
  getter customer : String | Customer | Nil
  getter description : String?
  getter? disputed : Bool
  getter payment_intent : String?
  getter payment_method_details : PaymentMethodDetails?
  getter receipt_email : String?
  getter? refunded : Bool
  getter shipping : Shipping?
  getter statement_descriptor : String?
  getter statement_descriptor_suffix : String?
  getter status : Status
  getter amount_captured : Int64
  getter amount_refunded : Int64
  getter application : String?
  getter application_fee : String?
  getter application_fee_amount : Int64?
  getter calculated_statement_descriptor : String?
  getter? captured : Bool
  getter failure_balance_transaction : String?
  getter failure_code : String?
  getter failure_message : String?
  getter fraud_details : FraudDetails?
  getter on_behalf_of : String?
  getter? paid : Bool
  getter payment_method : String?
  getter receipt_number : String?
  getter receipt_url : String?
  getter refunds : List(Refund)?
  getter review : String?
  getter source_transfer : String?
  getter transfer : String?
  getter transfer_data : TransferData?
  getter transfer_group : String?

  enum Status
    Pending
    Succeeded
    Failed
  end

  subresource BillingDetails,
    address : Address?,
    email : String?,
    name : String?,
    phone : String?,
    tax_id : String?

  subresource FraudDetails,
    stripe_report : Report?,
    user_report : Report? do
    enum Report
      Fraudulent
      Safe
    end
  end

  subresource TransferData,
    destination : String,
    amount : Int64? = nil
end
