require "./api"
require "./list"
require "./customer"
require "./tax_exemption"
require "./payment_method"

module Stripe
  API.define Customers do
    # TODO: Add params
    def list
      client.get "/v1/customers", as: List(Customer)
    end

    def retrieve(id : String)
      client.get "/v1/customers/#{id}", as: Customer
    end

    def search(metadata : NamedTuple | Hash)
      query = String.build do |str|
        metadata.each_with_index 1 do |key, value, index|
          if index > 1
            str << " AND "
          end
          str << %{metadata["} << key << %{"]:"} << value << '"'
        end
      end

      client.get "/v1/customers/search?#{URI::Params{"query" => query}}", as: List(Customer)
    end

    def create(
      name : String? = nil,
      email : String? = nil,
      description : String? = nil,
      metadata = nil,
      balance : Int? = nil,
      source : String? = nil,
      invoice_settings : Customer::InvoiceSettings? = nil,
      tax_exempt : TaxExemption? = nil,
    ) : Customer
      client.post "/v1/customers",
        form: {
          name:             name,
          email:            email,
          description:      description,
          metadata:         metadata,
          balance:          balance,
          source:           source,
          invoice_settings: invoice_settings,
          tax_exempt:       tax_exempt,
        },
        as: Customer
    end

    def update(
      customer : String | Customer,
      name : String? = nil,
      email : String? = nil,
      description : String? = nil,
      metadata = nil,
      balance : Int? = nil,
      source : String? = nil,
      invoice_settings : Customer::InvoiceSettings? = nil,
      tax_exempt : TaxExemption? = nil,
    ) : Customer
      customer = customer.id if customer.is_a? Customer

      client.post "/v1/customers/#{customer}",
        form: {
          name:             name,
          email:            email,
          description:      description,
          metadata:         metadata,
          balance:          balance,
          source:           source,
          invoice_settings: invoice_settings,
          tax_exempt:       tax_exempt,
        },
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
  end
end
