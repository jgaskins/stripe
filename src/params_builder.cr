module Stripe
  class ParamsBuilder
    @buffer = String::Builder.new
    private getter? written_first = false

    def self.from(**form)
      from form
    end

    def self.from(form : NamedTuple)
      instance = new
      form.each do |key, value|
        instance.add key.to_s, value
      end
      instance
    end

    def add(key : String, values : NamedTuple) : self
      values.each do |k, v|
        add "#{key}[#{k}]", v
      end
      self
    end

    def add(key : String, values : Array) : self
      key = "#{key}[]"
      values.each { |value| add key, value }
      self
    end

    def add(key : String, value : Enum) : self
      add key, value.to_s.underscore
    end

    def add(key : String, value : Bool) : self
      add key, value.to_s
    end

    def add(key : String, value : String) : self
      if written_first?
        @buffer << '&'
      end

      URI.encode_www_form(key, @buffer, space_to_plus: false)
      @buffer << '='
      URI.encode_www_form(value, @buffer, space_to_plus: false)
      @written_first = true
      self
    end

    def add(key : String, value : Nil) : self
      # Do nothing
      self
    end

    def to_s : String
      @buffer.to_s
    end

    def to_s(io) : Nil
      io << @buffer.to_s
    end
  end
end
