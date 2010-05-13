module Scopify
  class Scope
    def initialize(base, options)
      @base = base
      @options = options
    end

    def scoped(options)
      self.class.new(@base, options.merge(@options))
    end

    def to_hash
      @options
    end

    def method_missing(name, *args, &block)
      options = (args.first||{})
      options = options.merge(:limit => 1) if name.to_sym == :first
      options = scoped(options).to_hash
      @base.send(name, options , &block)
    end
  end
end