require "./resource"
require "./currency"

struct Stripe::LineItem
  include Resource

  getter quantity : Int64
  getter adjustable_quantity : AdjustableQuantity?
  getter dynamic_tax_rates : Array(String)?
  getter price : String?
  getter price_data : PriceData?

  def initialize(*, @price = nil, @price_data = nil, @adjustable_quantity = nil, @dynamic_tax_rates = nil, @quantity = 1)
  end

  struct PriceData
    include Resource

    getter currency : Currency
    getter product : String?
    getter product_data : ProductData?
    getter recurring : Recurring?
    getter tax_behavior : Price::TaxBehavior?

    def initialize(*, @currency, @product = nil, @product_data = nil, @recurring = nil, @tax_behavior = nil)
    end

    struct Recurring
      include Resource

      getter interval : Price::Interval
      getter interval_count : Int64

      def initialize(*, @interval, @interval_count)
      end
    end
  end

  struct ProductData
    include Resource

    getter name : String
    getter description : String?
    getter images : Array(String)?
    getter metadata : Metadata { Metadata.new }
    getter tax_code : String?

    def initialize(*, @name, @description = nil, @images = nil, @metadata = nil, @tax_code = nil)
    end
  end

  struct AdjustableQuantity
    include Resource

    getter? enabled : Bool
    getter maximum : Int64?
    getter minimum : Int64?

    def initialize(*, @enabled, @maximum = nil, @minimum = nil)
    end
  end
end
