require "http/client"

require "./log"

class Stripe::HTTPClient < HTTP::Client
  @last_request = Time.instant

  def before_checkout
    if @last_request.elapsed > 10.seconds
      Log.debug { "Closing stale connection" }
      close
      @last_request = Time.instant
    end
  end
end
