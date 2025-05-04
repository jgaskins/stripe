require "./spec_helper"

require "stripe/params_builder"
require "stripe/resource"

private enum MyEnum
  FooBar
end

private struct Person
  include Stripe::Resource

  getter name : String
  getter? bool_value : Bool

  # This one won't be serialized into params
  getter nil_value : String?

  def initialize(@name, @bool_value)
  end
end

describe Stripe::ParamsBuilder do
  it "URI-encodes simple params" do
    builder = Stripe::ParamsBuilder.new

    builder.add "name", "Foo"
    builder.add "type", "Bar"

    builder.to_s.should eq "name=Foo&type=Bar"
  end

  it "encodes empty strings" do
    builder = Stripe::ParamsBuilder.new

    builder.add "empty", ""
    builder.add "also_empty", ""

    builder.to_s.should eq "empty=&also_empty="
  end

  it "does not encode nil values" do
    builder = Stripe::ParamsBuilder.new

    builder.add "one", "1"
    builder.add "nope", nil

    builder.to_s.should eq "one=1"
  end

  it "encodes arrays" do
    builder = Stripe::ParamsBuilder.new

    builder.add "one", ["1", "uno"]

    builder.to_s.should eq URI::Params{"one[]" => %w[1 uno]}.to_s
  end

  it "encodes a NamedTuple" do
    builder = Stripe::ParamsBuilder.from(one: "1", two: nil)

    builder.to_s.should eq "one=1"
  end

  it "encodes an enum" do
    builder = Stripe::ParamsBuilder.from(one: MyEnum::FooBar)

    builder.to_s.should eq "one=foo_bar"
  end

  it "encodes complex params" do
    builder = Stripe::ParamsBuilder.from(
      omg: {
        lol: "wtf",
        # Test that we can encode arrays properly
        does: [
          # Testing nested objects
          {it: "work"},
          {it: "blend"},
        ],
        # Test that we can encode a Stripe::Resource
        person: Person.new(
          # Straightforward method, easy to test serialization for
          name: "Jamie",
          # The method name for this property ends in `?`, so this tests that
          # we can serialize those
          bool_value: true,
        ),
      },
      # Nested object
      subscription: {price: "asdf"},
    )

    URI::Params.parse(builder.to_s).should eq URI::Params{
      "omg[lol]"                => "wtf",
      "omg[does][][it]"         => %w[work blend],
      "omg[person][name]"       => "Jamie",
      "omg[person][bool_value]" => "true",
      "subscription[price]"     => "asdf",
    }
  end
end
