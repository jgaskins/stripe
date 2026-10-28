require "json"

require "./metadata"

module Stripe::Resource
  macro included
    include JSON::Serializable
  end

  getter id : String
  getter metadata : Stripe::Metadata { Stripe::Metadata.new }
  getter? livemode : Bool?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time

  macro define(type)
    struct {{type}}
      include ::Stripe::Resource

      {{yield}}
    end
  end

  macro subresource(type, *attrs)
    record {{type}}, {{attrs.splat}} do
      include JSON::Serializable

      macro subresource(type, *attrs)
        {% verbatim do %}
          ::Stripe::Resource.subresource {{type}}, {{attrs.splat}} do
            {{yield}}
          end
        {% end %}
      end

      {{yield}}
    end
  end
end
