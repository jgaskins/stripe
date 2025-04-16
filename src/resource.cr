require "json"

module Stripe::Resource
  macro included
    include JSON::Serializable
    include JSON::Serializable::Unmapped
  end

  macro define(type)
    struct {{type}}
      include ::Stripe::Resource

      {{yield}}
    end
  end
end
