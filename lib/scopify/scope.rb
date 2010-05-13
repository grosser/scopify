module Scopify
  class Scope
    def initialize(base, options)
      @base = base
      @options = options
    end

    def self.build(base, options)
      # :limit => 1 --> :limit => [1]
      options = options.inject({}){|h,kv| h[kv[0]]||=[]; h[kv[0]] << kv[1]; h}
      new(base, options)
    end

    def scoped(options)
      merged = @options.dup
      options.each do |k,v|
        merged[k] ||= []
        merged[k] << v
      end
      self.class.new(@base, merged)
    end

    def to_hash
      return @base.scope_to_hash(@options) if @base.respond_to?(:scope_to_hash)

      hash = {}
      @options.each do |k,v|
        hash[k] = case k
        when :limit, :offset then v.min
        when :order then v * ', '  
        else v 
        end
      end
      hash
    end

    def method_missing(name, *args, &block)
      options = (args.first||{})
      options = options.merge(:limit => 1) if name.to_sym == :first
      options = scoped(options).to_hash
      @base.send(name, options, &block)
    end
  end
end