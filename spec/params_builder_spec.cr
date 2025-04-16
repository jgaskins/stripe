require "./spec_helper"

require "../src/params_builder"

private enum MyEnum
  FooBar
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

    builder.to_s.should eq "one[]=1&one[]=uno"
  end

  it "encodes a NamedTuple" do
    builder = Stripe::ParamsBuilder.from(one: "1", two: nil)

    builder.to_s.should eq "one=1"
  end

  it "encodes an enum" do
    builder = Stripe::ParamsBuilder.from(one: MyEnum::FooBar)

    builder.to_s.should eq "one=foo_bar"
  end

  it "encodes nested NamedTuples with arrays" do
    builder = Stripe::ParamsBuilder.from(
      omg: {
        lol:  "wtf",
        does: [
          {it: "work"},
          {it: "blend"},
        ],
      },
      subscription: {price: "asdf"},
    )

    builder.to_s.should eq "omg[lol]=wtf&omg[does][][it]=work&omg[does][][it]=blend&subscription[price]=asdf"
  end
end
