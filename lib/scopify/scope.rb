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
      result = if @base.respond_to?(:scope_to_hash)
        @base.scope_to_hash(@options)
      else
        @options.map do |key, values|
          result = case key
          when :limit, :offset then values.min
          when :conditions
            if values.all?{|x| x.is_a?(Hash)}
              values.inject({}){|hash, x| hash.merge(x)}
            else
              "(#{values * ") AND ("})"
            end
          when :order then values * ', '
          else values
          end
          [key, result]
        end
      end

      if result.is_a?(Hash)
        result
      else
        # convert array to hash
        result.inject({}){|h, kv| h[kv[0]] = kv[1]; h}
      end
    end

    def method_missing(method_name, *args, &block)
      if @base.respond_to?(:raw_args_from_scope?) and @base.raw_args_from_scope?(method_name)
        # the method we call is a scope, continue chaining
        result = @base.send(method_name, *args, &block)
        result.is_a?(Scope) ? scoped(result) : result
      else
        # the method we call is a normal method
        # - scope by options from last method call
        # - flatten scope to options hash
        options = (args.last.is_a?(Hash) ? args.pop : {})
        options = scoped(options).to_hash
        args << options
        @base.send(method_name, *args, &block)
      end
    end
  end
end