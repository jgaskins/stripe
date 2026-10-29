require "./api"
require "./list"
require "./customer"
require "./tax_exemption"
require "./payment_method"

module Stripe
  API.define Customers do
    # TODO: Add params
    def list(*, expand : Expansions? = nil)
      client.get "/v1/customers",
        params: {expand: format_expand("data", expand)},
        as: List(Customer)
    end

    def retrieve(id : String, *, expand : Expansions? = nil)
      client.get "/v1/customers/#{id}",
        params: {expand: format_expand(nil, expand)},
        as: Customer
    end

    def search(query_data : NamedTuple | Hash, *, expand : Expansions? = nil)
      query = String.build do |str|
        query_data.each_with_index 1 do |key, value, index|
          if index > 1
            str << " AND "
          end
          str << key << %{:"} << value.gsub('"', %{\\"}) << '"'
        end
      end

      search query, expand: expand
    end

    def search(query : String, *, expand : Expansions? = nil)
      client.get "/v1/customers/search",
        params: {
          query:  query,
          expand: format_expand("data", expand),
        },
        as: List(Customer)
    end

    def create(
      name : String? = nil,
      email : String? = nil,
      description : String? = nil,
      phone : String? = nil,
      metadata = nil,
      balance : Int? = nil,
      source : String? = nil,
      invoice_prefix : String? = nil,
      invoice_settings : Customer::InvoiceSettings? = nil,
      address : Address? = nil,
      currency : Currency? = nil,
      default_source : String? = nil,
      tax_exempt : TaxExemption? = nil,
      delinquent : Bool? = nil,
      preferred_locales : Array(String)? = nil,
      shipping : Shipping? = nil,
      idempotency_key : String? = nil,
      expand : Expansions? = nil,
    ) : Customer
      client.post "/v1/customers",
        form: {
          name:              name,
          email:             email,
          description:       description,
          phone:             phone,
          metadata:          metadata,
          balance:           balance,
          source:            source,
          invoice_prefix:    invoice_prefix,
          invoice_settings:  invoice_settings,
          address:           address.try(&.to_named_tuple),
          currency:          currency,
          default_source:    default_source,
          tax_exempt:        tax_exempt,
          delinquent:        delinquent,
          preferred_locales: preferred_locales,
          shipping:          shipping.try(&.to_named_tuple),
          expand:            format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: Customer
    end

    def update(
      customer : String | Customer,
      name : String? = nil,
      email : String? = nil,
      description : String? = nil,
      phone : String? = nil,
      metadata = nil,
      balance : Int? = nil,
      source : String? = nil,
      invoice_prefix : String? = nil,
      invoice_settings : Customer::InvoiceSettings? = nil,
      address : Address? = nil,
      currency : Currency? = nil,
      default_source : String? = nil,
      tax_exempt : TaxExemption? = nil,
      delinquent : Bool? = nil,
      preferred_locales : Array(String)? = nil,
      shipping : Shipping? = nil,
      idempotency_key : String? = nil,
      expand : Expansions? = nil,
    ) : Customer
      customer = customer.id if customer.is_a? Customer

      client.post "/v1/customers/#{customer}",
        form: {
          name:              name,
          email:             email,
          description:       description,
          phone:             phone,
          metadata:          metadata,
          balance:           balance,
          source:            source,
          invoice_prefix:    invoice_prefix,
          invoice_settings:  invoice_settings,
          address:           address.try(&.to_named_tuple),
          currency:          currency,
          default_source:    default_source,
          tax_exempt:        tax_exempt,
          delinquent:        delinquent,
          preferred_locales: preferred_locales,
          shipping:          shipping.try(&.to_named_tuple),
          expand:            format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: Customer
    end

    # TODO: Add params
    def payment_methods(*, customer : String, limit : Int? = 0, type : PaymentMethod::Type? = nil) : List(PaymentMethod)
      client.get "/v1/customers/#{customer}/payment_methods",
        form: {
          limit: limit.try(&.to_s),
          type:  type,
        },
        as: List(PaymentMethod)
    end

    def_expand do
      Sources
      Subscriptions
      TestClock
    end

    alias Expansions = Union(
      Expand,
      Array(Expand),
      Array(String),
    )
  end
end
