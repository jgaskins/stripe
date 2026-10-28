require "./resource"

struct Stripe::Account
  include Resource

  getter object : String?
  getter applied_configurations : AppliedConfiguration?

  def initialize(
    @id,
    @object = nil,
    @applied_configurations = nil,
    @livemode = false,
    @created = Time.utc,
  )
  end

  @[Flags]
  enum AppliedConfiguration
    Customer
    Merchant
    Recipient
  end
end
