require "./client"

abstract struct Stripe::API
  protected getter client : Client

  def initialize(@client)
  end

  macro define(name)
    struct {{name}} < ::Stripe::API
      {{yield}}

      def expand(*expansions : String)
        expansions.to_a
      end

      def expand(*expansions : Expand)
        expansions.reduce { |acc, item| acc | item }
      end
    end

    class ::Stripe::Client
      def {{name.id.underscore}}
        {{name}}.new self
      end
    end
  end

  macro def_expand(&block)
    @[Flags]
    enum Expand
      {{block.body}}

      def to_params(prefix : String? = nil) : Array(String)
        params = [] of String
        each do |member|
          if prefix
            param = {prefix, member.to_s.underscore}.join('.')
          else
            param = member.to_s.underscore
          end

          params << param
        end
        params
      end
    end
  end

  def to_param(value : Enum)
    value.to_s.underscore
  end

  def to_param(value : Int)
    value.to_s
  end

  def to_param(value : Nil)
  end
end
