require "./client"

abstract struct Stripe::API
  protected getter client : Client

  def initialize(@client)
  end

  macro define(name)
    struct {{name}} < ::Stripe::API
      {{yield}}
    end

    class ::Stripe::Client
      def {{name.id.underscore}}
        {{name}}.new self
      end
    end
  end

  def to_param(value : Enum)
    value.to_s.underscore
  end

  def to_param(value : Int)
    value.to_s
  end

  def to_param(value : Nil)
  end
end
