require "./resource"

struct Stripe::AutomaticPaymentMethods
  include JSON::Serializable

  getter? enabled : Bool?
  getter allow_redirects : AllowRedirects?

  def initialize(*, @enabled = nil, @allow_redirects = nil)
  end

  protected def to_named_tuple
    {
      enabled:         enabled?,
      allow_redirects: allow_redirects,
    }
  end

  enum AllowRedirects
    Always
    Never
  end
end
