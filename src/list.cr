require "./resource"

struct Stripe::List(T)
  include Resource
  include Enumerable(T)

  getter url : String
  getter? has_more : Bool = false
  getter data : Array(T)

  delegate first, first?, each, to: data
end
