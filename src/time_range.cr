require "json"

module Stripe
  struct TimeRange
    include JSON::Serializable

    @[JSON::Field(converter: Time::EpochConverter)]
    getter gt : Time?
    @[JSON::Field(converter: Time::EpochConverter)]
    getter gte : Time?
    @[JSON::Field(converter: Time::EpochConverter)]
    getter lt : Time?
    @[JSON::Field(converter: Time::EpochConverter)]
    getter lte : Time?

    def self.new(range : Range(Time?, Time?))
      if range.excludes_end?
        new gte: range.begin, lt: range.end
      else
        new gte: range.begin, lte: range.end
      end
    end

    def initialize(
      @gt = nil,
      @gte = nil,
      @lt = nil,
      @lte = nil,
    )
    end
  end
end
