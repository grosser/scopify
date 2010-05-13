module Scopify
  class Scope
    def initialize(base, options)
      @base = base
      @options = options
    end

    def scope_options
      @options
    end

    def self.build(base, options)
      # :limit => 1 --> :limit => [1]
      options = options.inject({}){|h,kv| h[kv[0]]||=[]; h[kv[0]] << kv[1]; h}
      new(base, options)
    end

    def scoped(options)
      merged = @options.dup
      if options.is_a?(Scope)
        # merge in raw options e.g. :limit => [1, 2]
        options.scope_options.each do |k,v|
          merged[k] ||= []
          v.each{|x| merged[k] << x }
        end
      else
        # merge in a normal hash e.g. :limit => 1
        merged = @options.dup
        options.each do |k,v|
          merged[k] ||= []
          merged[k] << v
        end
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

    def method_missing(method_name, *args, &block)
      if @base.respond_to?("#{method_name}_scope_options")
        # the method we call is a scope, continue chaining
        scope = @base.send(method_name, *args)
        scope.scoped(self)
      else
        # the method we call is a normal method, flatten everything
        options = (args.first||{})
        options = options.merge(:limit => 1) if method_name.to_sym == :first
        options = scoped(options).to_hash
        @base.send(method_name, options, &block)
      end
    end
  end
end