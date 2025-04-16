module Stripe
  class Error < ::Exception
    macro define(name)
      class {{name}} < ::Stripe::Error
      end
    end
  end

  Error.define RequestError
end
