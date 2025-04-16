require "./api"
require "./list"
require "./product"

module Stripe
  API.define Products do
    def list(
      active : Bool? = nil,
    )
      client.get "/v1/products",
        params: {
          active: active,
        },
        as: List(Product)
    end

    def create(
      name : String,
      active : Bool? = nil,
      description : String? = nil,
      unit_label : String? = nil,
    )
      client.post "/v1/products",
        form: {
          name:        name,
          active:      active,
          description: description,
          unit_label:  unit_label,
        },
        as: Product
    end

    def update(
      product : Product | String,
      *,
      active : Bool? = nil,
    ) : Product
      product = product.id if product.is_a? Product
      client.post "/v1/products/#{product}",
        form: {
          active: active,
        },
        as: Product
    end

    def delete(product : Product | String)
      product = product.id if product.is_a? Product
      client.delete "/v1/products/#{product}", as: Product
    end
  end
end
