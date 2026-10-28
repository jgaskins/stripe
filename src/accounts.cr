require "./api"
require "./account"

module Stripe
  API.define Accounts do
    def list
      client.get "/v2/core/accounts", as: List(Account)
    end
  end
end
