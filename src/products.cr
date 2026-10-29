require "./api"
require "./list"
require "./product"
require "./prices"

module Stripe
  API.define Products do
    def list(
      active : Bool? = nil,
      expand : Expansions? = nil,
    )
      client.get "/v1/products",
        params: {
          active: active,
          expand: format_expand("data", expand),
        },
        as: List(Product)
    end

    def create(
      name : String,
      active : Bool? = nil,
      description : String? = nil,
      unit_label : String? = nil,
      idempotency_key : String? = nil,
      expand : Expansions? = nil,
    )
      client.post "/v1/products",
        form: {
          name:        name,
          active:      active,
          description: description,
          unit_label:  unit_label,
          expand:      format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: Product
    end

    def update(
      product : Product | String,
      *,
      active : Bool? = nil,
      expand : Expansions? = nil,
      idempotency_key : String? = nil,
    ) : Product
      product = product.id if product.is_a? Product
      client.post "/v1/products/#{product}",
        form: {
          active: active,
          expand: format_expand(nil, expand),
        },
        idempotency_key: idempotency_key,
        as: Product
    end

    def delete(product : Product | String)
      product = product.id if product.is_a? Product
      client.delete "/v1/products/#{product}", as: Product
    end

    def_expand do
      DefaultPrice
    end

    alias Expansions = Union(
      Expand,
      Array(Expand | Prices::Expand),
      Array(String),
    )

    private def format_expand_item(prefix : String?, expand : Prices::Expand)
      expand.to_params format_expand_item(prefix, "default_price")
    end
  end
end
