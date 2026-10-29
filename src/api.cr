require "./client"

abstract struct Stripe::API
  protected getter client : Client

  def initialize(@client)
  end

  macro define(name)
    struct {{name}} < ::Stripe::API
      {{yield}}
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

    def expand(*expansions : String)
      expansions.to_a
    end

    def expand(*expansions : Expand)
      expansions.reduce { |acc, item| acc | item }
    end

    private def format_expand(prefix : String?, expand : Expand)
      expand.to_params prefix
    end

    private def format_expand(prefix : String?, expand : Nil)
      nil
    end

    private def format_expand(prefix : String?, expand : Array)
      expand.flat_map { |item| format_expand_item prefix, item }
    end

    private def format_expand_item(prefix : String?, expand : Expand)
      expand.to_params prefix
    end

    private def format_expand_item(prefix : Nil, expand : String)
      expand
    end

    private def format_expand_item(prefix : String, expand : String)
      "#{prefix}.#{expand}"
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
