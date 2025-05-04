require "./resource"

struct Stripe::AutomaticPaymentMethods
  include Resource

  getter? enabled : Bool?
  getter allow_redirects : AllowRedirects?

  def initialize(*, @enabled, @allow_redirects)
  end

  enum AllowRedirects
    Always
    Never
  end
end
