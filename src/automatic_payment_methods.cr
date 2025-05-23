require "./resource"

struct Stripe::AutomaticPaymentMethods
  include Resource

  getter? enabled : Bool?
  getter allow_redirects : AllowRedirects?

  def initialize(*, @enabled = nil, @allow_redirects = nil)
  end

  enum AllowRedirects
    Always
    Never
  end
end
